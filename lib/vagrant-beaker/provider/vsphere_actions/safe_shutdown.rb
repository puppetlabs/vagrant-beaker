module VagrantPlugins
  module Beaker
    module Provider
      module VSphereActions
        class SafeShutdown
          def initialize( app, env )
            @app = app
            @logger = Log4r::Logger.new( 'vagrant_plugins::beaker::provider::vsphere_actions::safe_shutdown' )
          end

          def call( env )
            config     = env[:machine].provider_config
            vsphere    = env[:vsphere][:connection]
            connection = vsphere.instance_variable_get :@connection
            datacenter = connection.serviceInstance.find_datacenter

            metadata_file = File.join( env[:machine].data_dir.to_s, 'metadata.json' )

            if File.exists? metadata_file
              metadata    = JSON.parse( File.read( metadata_file ) )
              vm          = datacenter.find_vm( config.target_folder + '/' + metadata['machine_name'] )

              if vm.summary.runtime.powerState == 'poweredOn'
                if vm.summary.guest.toolsRunningStatus == 'guestToolsRunning'
                  env[:machine].ui.report_progress 0, 100
                  vm.ShutdownGuest

                  poll connection, vm, 'summary.runtime.powerState' do |i|
                    env[:machine].ui.clear_line
                    env[:machine].ui.report_progress i, 100

                    vm.summary.runtime.powerState == 'poweredOff'
                  end
                end
              end

            else
              raise 'VM metadata was deleted out from under Vagrant'
            end

            @app.call( env )
          end

          def poll( connection, vm, *properties, &block )
            filter = connection.propertyCollector.CreateFilter(
              spec: {
                propSet: [{
                           type:    'VirtualMachine',
                           all:      false,
                           pathSet:  properties
                         }],
                objectSet: [{ obj: vm }]
              },
              partialUpdates: false
            )

            # yeah, it's a really long name, but not as long as it took my
            # simple brain to figure out what the hell it was
            last_point_in_update_stream = ''
            polling = true

            # block until our tasks have succeeded or errored
            loop do
              result = connection.propertyCollector.WaitForUpdates(
                :version => last_point_in_update_stream
              )

              last_point_in_update_stream = result.version

              break if block.call

            end

            filter.DestroyPropertyFilter
          end
        end
      end
    end
  end
end

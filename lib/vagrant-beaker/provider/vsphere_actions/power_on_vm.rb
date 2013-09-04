module VagrantPlugins
  module Beaker
    module Provider
      module VSphereActions
        class PowerOnVM
          def initialize( app, env )
            @app = app
            @logger = Log4r::Logger.new( 'vagrant_plugins::beaker::provider::vsphere_actions::power_on_vm' )
          end

          def call( env )

            config  = env[:machine].provider_config
            vsphere = env[:vsphere][:connection]
            connection = vsphere.instance_variable_get :@connection

            metadata_file = File.join( env[:machine].data_dir.to_s, 'metadata.json' )
            metadata = JSON.parse( File.read( metadata_file ) )

            vm = connection.serviceInstance.find_datacenter.
              find_vm( config.target_folder + '/' + metadata['machine_name'] )

            env[:machine].ui.info 'Powering on VM and booting OS'
            env[:machine].ui.report_progress 0, 100

            unless vm.summary.runtime.powerState == 'poweredOn'
              vm.PowerOnVM_Task.wait_for_completion
            end

            env[:machine].ui.clear_line
            env[:machine].ui.report_progress 9, 100

            200.times do |i|
              sleep 2

              guest_summary = vm.summary.guest
              if( guest_summary.toolsRunningStatus == 'guestToolsRunning' and
                  guest_summary.ipAddress != nil )

                break

              else

                inc = i < 160 ? 9 + ( i / 4.0 ) : 49

                env[:machine].ui.clear_line
                env[:machine].ui.report_progress inc, 100
              end
            end

            env[:machine].ui.clear_line
            env[:machine].ui.report_progress 50, 100

            200.times do |i|
              sleep 2

              begin
                Socket.getaddrinfo( vm.name, nil)
                break
              rescue

                inc = i < 160 ? 49 + ( i / 4.0 ) : 99

                env[:machine].ui.clear_line
                env[:machine].ui.report_progress inc, 100
              end
            end

            begin
              Socket.getaddrinfo( vm.name, nil)
              env[:machine].ui.clear_line
              env[:machine].ui.report_progress 100, 100
            rescue
              raise 'VM failed to come up'
            end

            metadata['state']  = 'deployed-on'
            File.open( metadata_file, 'w+' ) {|f| f.write( metadata.to_json ) }


            vm.ReconfigVM_Task( spec: { annotation: metadata.to_json } )

            File.open( metadata_file, 'w+' ) {|f| f.write( metadata.to_json ) }
            File.open( File.join( env[:machine].data_dir.to_s, 'id' ), 'w+' ) { }

            env[:machine].ui.info 'VM ready'


            @app.call( env )
          end
        end
      end
    end
  end
end

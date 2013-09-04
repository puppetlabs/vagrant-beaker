module VagrantPlugins
  module Beaker
    module Provider
      module VSphereActions
        class PowerOffVM
          def initialize( app, env )
            @app = app
            @logger = Log4r::Logger.new( 'vagrant_plugins::beaker::provider::vsphere_actions::power_off_vm' )
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

              unless vm.summary.runtime.powerState == 'poweredOff'
                env[:machine].ui.info 'Powering off VM'
                env[:machine].ui.report_progress 0, 100
                task = vm.PowerOffVM_Task
                wait_for task, connection, env[:machine].ui
                env[:machine].ui.clear_line
                env[:machine].ui.report_progress 100, 100
              end

              metadata['state'] = 'deployed-off'

              File.open( metadata_file, 'w+' ) {|f| f.write( metadata.to_json ) }
              vm.ReconfigVM_Task( spec: { annotation: metadata.to_json } )

            else
              raise 'VM metadata was deleted out from under Vagrant'
            end


            @app.call( env )
          end

          def wait_for task, connection, ui
            filter = connection.propertyCollector.CreateFilter(
              spec: {
                propSet: [{
                           type:      'Task',
                           all:        false,
                           pathSet: [ 'info.state',
                                      'info.progress' ]
                         }],
                objectSet: [{ obj: task }]
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

              if ['success', 'error'].member? task.info.state
                break
              else
                ui.clear_line
                ui.report_progress task.info.progress, 100
              end
            end

            filter.DestroyPropertyFilter

            # fail if we weren't successful
            raise 'Failed to clone VM' if task.info.state == 'error'
          end
        end
      end
    end
  end
end

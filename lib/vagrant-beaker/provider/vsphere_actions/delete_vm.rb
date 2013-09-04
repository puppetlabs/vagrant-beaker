module VagrantPlugins
  module Beaker
    module Provider
      module VSphereActions
        class DeleteVM
          def initialize( app, env )
            @app = app
            @logger = Log4r::Logger.new( 'vagrant_plugins::beaker::provider::vsphere_actions::delete_vm' )
          end

          def call( env )

            config  = env[:machine].provider_config
            vsphere = env[:vsphere][:connection]
            connection = vsphere.instance_variable_get :@connection

            metadata_file = File.join( env[:machine].data_dir.to_s, 'metadata.json' )
            metadata = JSON.parse( File.read( metadata_file ) )

            vm = connection.serviceInstance.find_datacenter.
              find_vm( config.target_folder + '/' + metadata['machine_name'] )

            task = vm.Destroy_Task

            File.unlink( *(env[:machine].data_dir.children.map{|c| c.to_s }) )
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

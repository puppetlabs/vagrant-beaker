module VagrantPlugins
  module Beaker
    module Provider
      module VSphereActions
        class CheckState
          def initialize( app, env )
            @app = app
            @logger = Log4r::Logger.new( 'vagrant_plugins::beaker::provider::vsphere_actions::check_state' )
          end

          def call( env )
            config     = env[:machine].provider_config
            vsphere    = env[:vsphere][:connection]
            connection = vsphere.instance_variable_get :@connection
            datacenter = connection.serviceInstance.find_datacenter

            metadata_file = File.join( env[:machine].data_dir.to_s, 'metadata.json' )
            state = nil

            if File.exists? metadata_file
              metadata    = JSON.parse( File.read( metadata_file ) )
              vm          = datacenter.find_vm( config.target_folder + '/' + metadata['machine_name'] )

              if vm
                sync vm, metadata, metadata_file

                state = metadata['state']
              else

                raise 'Local VM data was changed out from under Vagrant'
              end

            else

              results     = retreive_remotes_for( config.username, connection )
              vagrant_ref = env[:root_path].to_s + '/Vagrantfile/' + env[:machine].name.to_s
              result      = results.select {|r| r[:metadata]['vagrant_ref'] == vagrant_ref }.first

              if result
                metadata = result[:metadata]
                sync result[:vm], metadata, metadata_file
                register_machine env[:machine]

                state = metadata['state']
              else

                state = 'unprovisioned'
              end

            end

            env[:machine_state_id] = state
            @app.call( env )
          end

          def register_machine( machine )
            File.open( File.join( machine.data_dir.to_s, 'id' ), 'w+' ) {|f| }
          end

          def sync( vm, metadata, metadata_file )
            state = vm.summary.runtime.powerState == 'poweredOn' ? 'deployed-on' : 'deployed-off'
            metadata['state'] = state
            vm.ReconfigVM_Task( spec: { annotation: metadata.to_json } ).wait_for_completion
            File.open( metadata_file, 'w+' ) {|f| f.write( metadata.to_json ) }
          end

          def retreive_remotes_for( user, connection )
            filter = {
              specSet: [{
                objectSet: [{
                  obj: connection.serviceContent.viewManager.CreateContainerView(
                    container: connection.serviceContent.rootFolder,
                    recursive: true,
                    type:      [ 'VirtualMachine' ]
                  ),
                  skip: true,
                  selectSet: [ RbVmomi::VIM::TraversalSpec.new(
                      name: '',
                      path: 'view',
                      skip:  false,
                      type: 'ContainerView'
                  )]
                }],
                propSet: [{ pathSet: [ 'config.annotation' ],
                            type:    'VirtualMachine' }]
              }],
              options: { maxObjects: nil }
            }

            results = connection.serviceContent.propertyCollector.RetrievePropertiesEx( filter )

            objects = results.objects.select do |o|
              value = o.propSet.first.val
              value =~ /"vagrant_ref":/ and
              value =~ Regexp.new(Regexp.escape( user ))
            end

            objects.map {|o| { vm: o.obj, metadata: JSON.parse( o.propSet.first.val ) } }
          end
        end
      end
    end
  end
end

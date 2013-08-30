require 'securerandom'
require 'json'
require 'log4r'

module VagrantPlugins
  module Beaker
    module Provider
      module VSphereActions
        class CloneTemplate
          def initialize( app, env )
            @app = app
            @logger = Log4r::Logger.new( 'vagrant::beaker::provider::vsphere_actions::clone_template' )
          end

          def call( env )

            config  = env[:machine].provider_config
            vsphere = env[:vsphere][:connection]
            connection = vsphere.instance_variable_get :@connection

            username_without_dn = config.username.split('@')[0]
            if username_without_dn =~ /\./
              first_name, last_name = username_without_dn.split('.')
              username = first_name[0..10] + last_name[0..1]
            else
              username = username_without_dn[0..11]
            end

            random = [ 'a'..'z', 'A'..'Z', 0..9 ].flat_map {|r| r.to_a }.sample( 5 ).join
            vmname = username + '-' + random

            metadata = {
              machine_name: vmname,
              state: 'unprovisioned',
              mo_ref: nil,
              vagrant_ref: env[:root_path].to_s + '/Vagrantfile/' + env[:machine].name.to_s,
              id: nil,
              created_on: Time.now.getutc,
              created_by: config.username
            }

            metadata_file = File.join( env[:machine].data_dir.to_s, 'metadata.json' )

            File.open( metadata_file, 'w+' ) {|f| f.write( metadata.to_json ) }

            template = connection.serviceInstance.find_datacenter.find_vm( config.template )

            relocateSpec = RbVmomi::VIM.VirtualMachineRelocateSpec(
              datastore:     vsphere.find_datastore( config.target_datastore ),
              pool:          vsphere.find_pool( config.target_resource_pool ),
              diskMoveType: :moveChildMostDiskBacking
            )

            customizationSpec = vsphere.find_customization( config.template )

            configSpec = RbVmomi::VIM.VirtualMachineConfigSpec( annotation: metadata.to_json )

            spec = RbVmomi::VIM.VirtualMachineCloneSpec(
              config:        configSpec,
              location:      relocateSpec,
              customization: customizationSpec,
              powerOn:       false,
              template:      false
            )

            target_folder = vsphere.find_folder( config.target_folder )

            env[:machine].ui.info 'Cloning VM'

            clone_task = template.CloneVM_Task( name:   vmname,
                                                spec:   spec,
                                                folder: target_folder )


            env[:machine].ui.report_progress 0, 100

            filter = connection.propertyCollector.CreateFilter(
              spec: {
                propSet: [{
                           type:      'Task',
                           all:        false,
                           pathSet: [ 'info.state',
                                      'info.progress' ]
                         }],
                objectSet: [{ obj: clone_task }]
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

              if ['success', 'error'].member? clone_task.info.state
                break
              else
                env[:machine].ui.clear_line
                env[:machine].ui.report_progress clone_task.info.progress, 100
              end
            end

            filter.DestroyPropertyFilter

            # fail if we weren't successful
            raise 'Failed to clone VM' if clone_task.info.state == 'error'

            machine = connection.serviceInstance.find_datacenter.find_vm( config.target_folder + '/' + vmname )

            metadata[:mo_ref] =  machine._ref
            metadata[:id]     =  machine.config.instanceUuid
            metadata[:state]  = 'provisoned-off'

            env[:vsphere][:machine]  = machine
            env[:vsphere][:metadata] = metadata

            configSpec = RbVmomi::VIM.VirtualMachineConfigSpec( annotation: metadata.to_json )
            machine.ReconfigVM_Task( spec: configSpec ).wait_for_completion

            File.open( metadata_file, 'w+' ) {|f| f.write( metadata.to_json ) }


            env[:machine].ui.info 'Completed clone'


            @app.call( env )
          end
        end
      end
    end
  end
end

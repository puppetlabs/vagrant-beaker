require 'securerandom'
require 'json'
require 'log4r'

module VagrantPlugins
  module Beaker
    module Provider
      module VSphereActions
        class PowerOnVM
          def initialize( app, env )
            @app = app
            @logger = Log4r::Logger.new( 'vagrant::beaker::provider::vsphere_actions::clone_template' )
          end

          def call( env )

            config  = env[:machine].provider_config
            vsphere = env[:vsphere][:connection]

            metadata = env[:vsphere][:metadata]
            metadata[:state]  = 'provisoned-on'
            machine = env[:vsphere][:machine]

            metadata_file = File.join( env[:machine].data_dir.to_s, 'metadata.json' )

            env[:machine].ui.info 'Powering on VM and booting OS'

            env[:machine].ui.report_progress 0, 100

            machine.PowerOnVM_Task.wait_for_completion

            env[:machine].ui.clear_line
            env[:machine].ui.report_progress 9, 100

            200.times do |i|
              sleep 2

              guest_summary = machine.summary.guest
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
                Socket.getaddrinfo( machine.name, nil)
                break
              rescue

                inc = i < 160 ? 49 + ( i / 4.0 ) : 99

                env[:machine].ui.clear_line
                env[:machine].ui.report_progress inc, 100
              end
            end

            begin
              Socket.getaddrinfo( machine.name, nil)
              env[:machine].ui.clear_line
              env[:machine].ui.report_progress 100, 100
            rescue
              raise 'VM failed to come up'
            end

            File.open( metadata_file, 'w+' ) {|f| f.write( metadata.to_json ) }

            configSpec = RbVmomi::VIM.VirtualMachineConfigSpec( annotation: metadata.to_json )
            machine.ReconfigVM_Task( spec: configSpec ).wait_for_completion

            File.open( metadata_file, 'w+' ) {|f| f.write( metadata.to_json ) }

            env[:machine].ui.info 'VM ready'


            @app.call( env )
          end
        end
      end
    end
  end
end

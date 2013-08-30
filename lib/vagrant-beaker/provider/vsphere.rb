require_relative 'vsphere_actions'

module VagrantPlugins
  module Beaker
    module Provider
      class VSphere < Vagrant.plugin( 2, :provider )
        include Vagrant::Action::Builtin
        include VagrantPlugins::Beaker::Provider::VSphereActions

        attr_reader :machine
        def initialize( machine )
          @machine = machine
        end

        def action( name )
          self.send( "#{name}_action" )
        end

        def machine_id_changed
        end

        def ssh_info
        end

        def state
          env = machine.action( 'check_state' )

          scope = 'vagrant.beaker.states.'

          state_id    = env[:machine_state_id]
          summary     = I18n.t( scope + state_id.to_s + '.summary'     )
          description = I18n.t( scope + state_id.to_s + '.description' )

          Vagrant::MachineState.new( state_id, summary, description )
        end

        def up_action
          Vagrant::Action::Builder.new.tap do |toplevel|
            toplevel.use ConfigValidate
            toplevel.use EnsureConnection
            toplevel.use Call, CheckIfExists do |env, sublevel|
              if env[:machine_exists]
                sublevel.use AlreadyExists
                next
              end

              sublevel.use CloneTemplate
              sublevel.use PowerOnVM
              sublevel.use EnsureNetworking
            end
          end
        end

        def check_state_action
          Vagrant::Action::Builder.new.tap do |toplevel|
            toplevel.use CheckState
          end
        end
      end
    end
  end
end

require 'securerandom'
require 'json'
require 'beaker/hypervisor/vsphere_helper'
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
          metadata = JSON.parse( File.read( machine.data_dir.to_s + '/' + 'metadata.json' ) )
          return { host:      metadata['machine_name'],
                   username: 'root',
                   port:      22                         }
        end

        def state
          env = machine.action( 'check_state' )

          scope = 'vagrant_plugins.beaker.states.'

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
                sublevel.use WarnAlreadyExists
              else
                sublevel.use CloneTemplate
              end

              sublevel.use PowerOnVM
              sublevel.use WarnNetworking
              sublevel.use CloseConnection
            end
          end
        end

        def check_state_action
          Vagrant::Action::Builder.new.tap do |toplevel|
            toplevel.use ConfigValidate
            toplevel.use EnsureConnection
            toplevel.use CheckState
          end
        end

        def halt_action
          Vagrant::Action::Builder.new.tap do |toplevel|
            toplevel.use ConfigValidate
            toplevel.use EnsureConnection
            toplevel.use Call, CheckIfExists do |env, sublevel|
              if env[:machine_exists]
                sublevel.use SafeShutdown
                sublevel.use PowerOffVM
              else
                sublevel.use RemoveLocalState
                sublevel.use WarnNotFound
              end

              sublevel.use CloseConnection
            end
          end
        end

        def ssh_action
          Vagrant::Action::Builder.new.tap do |b|
            b.use ConfigValidate
            b.use Call, CheckIfExists do |env, b2|
              if not env[:machine_exists]
                b2.use WarnNotFound
                next
              end

              b2.use SSHExec
            end
          end
        end

        def destroy_action
          Vagrant::Action::Builder.new.tap do |toplevel|
            toplevel.use ConfigValidate
            toplevel.use EnsureConnection
            toplevel.use Call, CheckIfExists do |env, sublevel|
              if env[:machine_exists]
                sublevel.use PowerOffVM
                sublevel.use DeleteVM
              else
                sublevel.use WarnNotFound
              end

              sublevel.use RemoveLocalState
              sublevel.use CloseConnection
            end
          end
        end

        def provision_action
        end
      end
    end
  end
end

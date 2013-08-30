require 'log4r'

module VagrantPlugins
  module Beaker
    module Provider
      module VSphereActions
        class CheckState
          def initialize( app, env )
            @app = app
            @logger = Log4r::Logger.new( 'vagrant::beaker::provider::vsphere_actions::check_if_exists' )
          end

          def call( env )
            env[:machine_state_id] = :noop
            @app.call( env )
          end
        end
      end
    end
  end
end

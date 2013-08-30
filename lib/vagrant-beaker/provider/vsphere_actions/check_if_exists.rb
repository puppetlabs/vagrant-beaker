require 'log4r'

module VagrantPlugins
  module Beaker
    module Provider
      module VSphereActions
        class CheckIfExists
          def initialize( app, env )
            @app = app
            @logger = Log4r::Logger.new( 'vagrant::beaker::provider::vsphere_actions::check_if_exists' )
          end

          def call( env )
            env[:machine_exists] = env[:machine].state.id === :deployed
            @app.call( env )
          end
        end
      end
    end
  end
end

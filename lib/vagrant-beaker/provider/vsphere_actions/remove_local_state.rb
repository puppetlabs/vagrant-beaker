module VagrantPlugins
  module Beaker
    module Provider
      module VSphereActions
        class RemoveLocalState
          def initialize( app, env )
            @app = app
            @logger = Log4r::Logger.new( 'vagrant_plugins::beaker::provider::vsphere_actions::remove_local_state' )
          end

          def call( env )

            @app.call( env )
          end
        end
      end
    end
  end
end

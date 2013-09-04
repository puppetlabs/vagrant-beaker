module VagrantPlugins
  module Beaker
    module Provider
      module VSphereActions
        class WarnNetworking
          def initialize( app, env )
            @app = app
            @logger = Log4r::Logger.new( 'vagrant_plugins::beaker::provider::vsphere_actions::warn_networking' )
          end

          def call( env )
            env[:ui].info I18n.t( 'vagrant_plugins.beaker.provider.warn_networking' )
            @app.call( env )
          end
        end
      end
    end
  end
end

module VagrantPlugins
  module Beaker
    module Provider
      module VSphereActions
        class WarnAlreadyExists
          def initialize( app, env )
            @app = app
            @logger = Log4r::Logger.new( 'vagrant_plugins::beaker::provider::vsphere_actions::warn_already_exists' )
          end

          def call( env )
            env[:ui].info I18n.t( 'vagrant_plugins.beaker.provider.warn_already_exists' )
            @app.call( env )
          end
        end
      end
    end
  end
end

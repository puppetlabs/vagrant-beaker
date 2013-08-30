require 'log4r'

module VagrantPlugins
  module Beaker
    module Provider
      module VSphereActions
        class AlreadyExists
          def initialize( app, env )
            @app = app
            @logger = Log4r::Logger.new( 'vagrant::beaker::provider::vsphere_actions::check_if_exists' )
          end

          def call( env )
            env[:ui].info I18n.t( 'vagrant.beaker.provider.already_exists' )
            @app.call( env )
          end
        end
      end
    end
  end
end

require 'log4r'

module VagrantPlugins
  module Beaker
    module Provider
      module VSphereActions
        class EnsureNetworking
          def initialize( app, env )
            @app = app
            @logger = Log4r::Logger.new( 'vagrant::beaker::provider::vsphere_actions::ensure_networking' )
          end

          def call( env )
            @app.call( env )
          end
        end
      end
    end
  end
end

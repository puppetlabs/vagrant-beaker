module VagrantPlugins
  module Beaker
    module Provider
      module VSphereActions
        class CloseConnection
          def initialize( app, env )
            @app = app
            @logger = Log4r::Logger.new( 'vagrant_plugins::beaker::provider::vsphere_actions::close_connnection' )
          end

          def call( env )
            config = env[:machine].provider_config

            env[:vsphere] ||= {}
            env[:vsphere][:connection] && env[:vsphere][:connection].close

            @app.call( env )
          end
        end
      end
    end
  end
end

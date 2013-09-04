module VagrantPlugins
  module Beaker
    module Provider
      module VSphereActions
        class EnsureConnection
          def initialize( app, env )
            @app = app
            @logger = Log4r::Logger.new( 'vagrant_plugins::beaker::provider::vsphere_actions::ensure_connnection' )
          end

          def call( env )
            config = env[:machine].provider_config

            env[:vsphere] ||= {}
            unless env[:vsphere][:connection]
              env[:machine].ui.info "Connecting to vSphere...."
              env[:vsphere][:connection] = VsphereHelper.new({
                user:   config.username,
                pass:   config.password,
                server: config.server,
                logger: env[:machine].ui
              })
            end

            @app.call( env )
          end
        end
      end
    end
  end
end

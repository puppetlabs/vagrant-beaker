module VagrantPlugins
  module Beaker
    module Provider
      class VSphereConfig < Vagrant.plugin( 2, :config )

        attr_accessor :template, :template_folder, :target_folder,
                      :target_resource_pool, :target_datastore, :username,
                      :password, :server

        def validate!
          {}
        end
      end
    end
  end
end

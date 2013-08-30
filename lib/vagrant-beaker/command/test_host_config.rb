module VagrantPlugins
  module Beaker
    module Command
      class TestHostConfig < Vagrant.plugin( 2, :config )

        attr_accessor :roles

        def initialize
          @roles = UNSET_VALUE
        end

        def finalize!
          @roles = [] if @roles == UNSET_VALUE
        end
      end
    end
  end
end

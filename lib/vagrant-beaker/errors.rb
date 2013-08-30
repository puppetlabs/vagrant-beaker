module VagrantPlugins
  module Beaker
    module Errors
      class BeakerError < Vagrant::Errors::VagrantError
        error_namespace 'vagrant.beaker'
      end
    end
  end
end

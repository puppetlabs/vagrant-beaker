require_relative 'vsphere_actions/already_exists'
require_relative 'vsphere_actions/check_if_exists'
require_relative 'vsphere_actions/check_state'
require_relative 'vsphere_actions/clone_template'
require_relative 'vsphere_actions/ensure_connection'
require_relative 'vsphere_actions/ensure_networking'
require_relative 'vsphere_actions/power_on_vm'

module VagrantPlugins
  module Beaker
    module Provider
      module VSphereActions
      end
    end
  end
end


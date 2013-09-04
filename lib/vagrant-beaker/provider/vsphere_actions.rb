require_relative 'vsphere_actions/check_if_exists'
require_relative 'vsphere_actions/check_state'
require_relative 'vsphere_actions/clone_template'
require_relative 'vsphere_actions/close_connection'
require_relative 'vsphere_actions/delete_vm'
require_relative 'vsphere_actions/ensure_connection'
require_relative 'vsphere_actions/power_off_vm'
require_relative 'vsphere_actions/power_on_vm'
require_relative 'vsphere_actions/remove_local_state'
require_relative 'vsphere_actions/safe_shutdown'
require_relative 'vsphere_actions/warn_already_exists'
require_relative 'vsphere_actions/warn_networking'
require_relative 'vsphere_actions/warn_not_found'

module VagrantPlugins
  module Beaker
    module Provider
      module VSphereActions
      end
    end
  end
end


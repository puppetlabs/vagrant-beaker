require_relative 'vagrant-beaker/version'
require_relative 'vagrant-beaker/plugin'
require_relative 'vagrant-beaker/errors'


module VagrantPlugins
  module Beaker
    include VagrantPlugins::Beaker::Errors
  end
end

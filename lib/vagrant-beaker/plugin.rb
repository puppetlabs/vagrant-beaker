begin
  require 'vagrant'
rescue LoadError
  raise 'Vagrant cannot be found, please install VagrantBeaker as a Vagrant plugin or load the dev environment!'
end

if Vagrant::VERSION < '1.2.0'
  raise 'VagrantBeaker requires Vagrant version 1.2 or greater'
end

module VagrantPlugins
  module Beaker
    class Plugin < Vagrant.plugin( '2' )
      name 'beaker'

      provider 'delivery' do
        setup!

        require_relative 'provider/vsphere'
        VagrantPlugins::Beaker::Provider::VSphere
      end

      config :delivery, :provider do
        setup!

        require_relative 'provider/vsphere_config'
        VagrantPlugins::Beaker::Provider::VSphereConfig
      end

      command 'test' do
        setup!

        require_relative 'command/test'
        VagrantPlugins::Beaker::Command::Default
      end

      config :integration do
        setup!

        # contains the monkey patch so that we can call `config.vm.roles`
        require_relative 'command/test_runner_config'
        VagrantPlugins::Beaker::Command::TestRunnerConfig
      end

      config :testing do
        setup!

        require_relative 'command/test_host_config'
        VagrantPlugins::Beaker::Command::TestHostConfig
      end

      def self.setup!
        setup_internationalization
        setup_logging
      end

      def self.setup_internationalization
        locale_dir = File.expand_path( File.dirname(__FILE__) + '/../../locales' )
        locale_files = Dir[locale_dir + '/*.yml']

        I18n.load_path += locale_files
        I18n.reload!
      end

      def self.setup_logging
        require "log4r"

        level = nil
        begin
          level = Log4r.const_get(ENV["VAGRANT_LOG"].upcase)
        rescue NameError
          # This means that the logging constant wasn't found,
          # which is fine. We just keep `level` as `nil`. But
          # we tell the user.
          level = nil
        end

        # Some constants, such as "true" resolve to booleans, so the
        # above error checking doesn't catch it. This will check to make
        # sure that the log level is an integer, as Log4r requires.
        level = nil if !level.is_a?(Integer)

        # Set the logging level on all "vagrant" namespaced
        # logs as long as we have a valid level.
        if level
          logger = Log4r::Logger.new("vagrant::beaker")
          logger.outputters = Log4r::Outputter.stderr
          logger.level = level
          logger = nil
        end
      end
    end
  end
end

module VagrantPlugins
  module Beaker
    module Provider
      class VSphereConfig < Vagrant.plugin( 2, :config )

        #class ConfigError < Vagrant::Errors::VagrantError
        #  error_namespace 'vagrant_plugins.beaker.provider.vsphere'
        #end

        SCOPE= 'vagrant_plugins.beaker.provider.vsphere.'

        attr_accessor :template, :template_folder, :template_name,
                      :target_folder, :target_resource_pool, :target_datastore,
                      :default_template_name, :default_target_folder,
                      :default_resource_pool,
                      :username, :password, :server

        def initialize
          @template              = UNSET_VALUE
          @template_folder       = UNSET_VALUE
          @template_name         = UNSET_VALUE
          @target_folder         = UNSET_VALUE
          @target_resource_pool  = UNSET_VALUE
          @default_template_name = UNSET_VALUE
          @default_target_folder = UNSET_VALUE
          @default_resource_pool = UNSET_VALUE
          @username              = UNSET_VALUE
          @password              = UNSET_VALUE
          @server                = UNSET_VALUE
        end

        def validate( machine )
          errors = {}
          errors[:template_path] = [ I18n.t( SCOPE + 'unknown_template_path' ) ] unless @username
          errors[:password]      = [ I18n.t( SCOPE + 'no_password' ) ]           unless @username
          errors[:username]      = [ I18n.t( SCOPE + 'no_username' ) ]           unless @username
          errors[:server]        = [ I18n.t( SCOPE + 'no_server' ) ]             unless @username
        end

        def finalize!
          @template             = nil if @template        == UNSET_VALUE
          @template_folder      = nil if @template_folder == UNSET_VALUE
          @template_name        = nil if @template_name   == UNSET_VALUE

          @target_folder        = nil if @target_folder        == UNSET_VALUE
          @target_resource_pool = nil if @target_resource_pool == UNSET_VALUE

          @default_resource_pool = nil if @default_resource_pool == UNSET_VALUE
          @default_target_folder = nil if @default_target_folder == UNSET_VALUE
          @default_template_name = nil if @default_template_name == UNSET_VALUE

          @username = nil if @username == UNSET_VALUE
          @password = nil if @password == UNSET_VALUE
          @server   = nil if @server   == UNSET_VALUE

          @template_name        ||= @default_template_name
          @target_folder        ||= @default_target_folder
          @target_resource_pool ||= @default_resource_pool

          unless @template
            if @template_folder and @template_name
              @template = @template_folder + '/' + @template_name
            end
          end

          #@template             = make_env_substitutions( @template )
          #@target_folder        = make_env_substitutions( @target_folder )
          #@target_resource_pool = make_env_substitutions( @target_resource_pool )
        end

        #def make_env_substitutions( template_string )
        #  if match = template_string.to_s.match(/%(\w+)%/)
        #    variables = match[1..-1]

        #    variables.inject( template_string ) do |string, variable|
        #      string.gsub( /%#{variable}%/, ENV[variable] )
        #    end
        #  end
        #end
      end
    end
  end
end

module VagrantPlugins
  module Beaker
    module Command
      class Default < Vagrant.plugin( 2, :command )

        def initialize *args
          super
          @options = {}
          parse_options( parser )
        end

        def execute
          @env.ui.info @options[:output]
          @env.ui.info vms.first.config.integration.tests.first
          @env.ui.info vms.first.config.testing.roles

          return 0
        end

        def parser
          OptionParser.new do |cli|
            cli.banner = 'Usage: vagrant test path/to/tests'
            cli.separator ''

            cli.on( '-o THING', '--output THING', 'Puts shit' ) do |shit|
              @options[:output] = shit
            end
          end
        end

        def vms
          @vms ||= get_vms
        end

        def get_vms
          vm_holder = []
          with_target_vms do |vm|
            vm_holder << vm
          end
          vm_holder
        end
      end
    end
  end
end

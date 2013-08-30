module VagrantPlugins
  module Beaker
    module Command
      class TestRunnerConfig < Vagrant.plugin( 2, :config )

        def initialize
          @tests  = UNSET_VALUE
          @helper = UNSET_VALUE
        end

        def tests=( one_or_more_tests )
          @tests = Array( one_or_more_tests )
        end

        def tests
          @tests
        end

        def helper
          @helper
        end

        def helper=( one_or_more_helpers )
          @helper = Array( one_or_more_helpers )
        end

        def merge( other )
          super.tap do |result|
            result.tests  = tests | other.tests
            result.helper = helper | other.helper
          end
        end

        def finalize!
          @tests  = [] if @tests == UNSET_VALUE
          @helper = [] if @helper == UNSET_VALUE
        end

        def validate( machine )
          {}
        end
      end
    end
  end
end

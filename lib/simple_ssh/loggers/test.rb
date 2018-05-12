require 'simple_ssh/loggers/file_path'

module SimpleSsh
  module Loggers

    # A basic output logger that dumps output to a test log file.
    class Test < FilePath

      def initialize
        super('./simple_ssh_test.log')

        self.info("-"*80)
        self.info("Test started!")
      end
    end

  end
end

require 'simple_ssh/loggers/default'

module SimpleSsh
  module Loggers

    # A basic output logger that dumps output to a test log file.
    class Test < Default

      def initialize
        @file   = nil
        begin
          @file   = file.open('./simple_ssh_test.log', 'w')
        rescue Exception => e
          puts "!!! Could not open the test log file: #{e.message} -- continuing without logging"
          @file   = nil
        end
      end

      def write(msg)
        @file.puts msg unless @file.nil?
      end
    end

  end
end

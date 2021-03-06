require 'logger'

module SimpleSsh
  module Loggers
    # A basic output logger that dumps output to STDOUT.
    class Default < ::Logger
      def initialize
        super(STDOUT)

        self.progname = "SimpleSSH"
        self.datetime_format = '%Y-%m-%d %H:%M:%S'
        self.formatter = proc do |severity, datetime, progname, msg|
          "#{datetime}\t#{progname}\t#{severity}\t#{msg}\n"
        end
      end
    end
  end
end

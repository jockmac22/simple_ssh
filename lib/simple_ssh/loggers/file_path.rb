require 'simple_ssh/loggers/default'

module SimpleSsh
  module Loggers

    # A basic output logger that dumps output to a test log file.
    class FilePath < Logger

      def initialize(file_path)
        super(file_path, 'daily')

        self.progname = "SimpleSSH"
        self.datetime_format = '%Y-%m-%d %H:%M:%S'
        self.formatter = proc do |severity, datetime, progname, msg|
          "#{datetime}\t#{progname}\t#{severity}\t#{msg}\n"
        end
      end
    end

  end
end

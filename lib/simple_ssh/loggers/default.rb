module SimpleSsh
  module Loggers
    # A basic output logger that dumps output to STDOUT.
    class Default
      def method_missing(method, *args)
        self.write("#{method.to_s.upcase}: #{args.map{ |a| a.to_s }.join(" ")}")
      end

      def write(msg)
        puts msg
      end
    end
  end
end

module SimpleSsh
  class Commands

    def initialize(options={})
      @mode     = options.fetch(:mode,      :chain)
      @list     = options.fetch(:commands,  [])
    end

    # Adds a command to the command list.
    #
    # @param command [String] The command to add to the command chain
    #
    def << (command)
      @list ||= []
      @list << command
    end

    # Clears out the command list.
    #
    def clear!()
      @list = nil
    end

    # Add a command directly to the list
    #
    def cmd!(command)
      self << command
    end

    # Generates the join string used to join multiple shell commands based on
    # the current execution mode.
    #
    # @return [String] The command join string
    #
    def command_join_string!
      (@mode == :pipe) ? " | " : " && "
    end

    # Returns the commands as a string with the proper join string.
    #
    def to_s
      s = @list.join(command_join_string!)
      s
    end

    def to_str
      to_s
    end

    # Returns the array of commands.
    #
    def to_a
      @list
    end

    # Turn any previously undefined method call into a shell command.
    #
    def method_missing(method, *args)
      puts "Method Missing: #{method} | #{args}"
      args.unshift(method.to_s)
      self << args.join(" ")
    end
  end
end

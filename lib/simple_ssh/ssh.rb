require 'colorize'

module SimpleSsh
  class Ssh

    # @attr [Symbol] The mode of the SSH execution.  Can be :single, :chain or :pipe
    attr_reader :execution_mode

    # @attr [Hash] The current configuration of this SSH instance.
    attr_reader :config

    def initialize(overrides={})
      @execution_mode = overrides.fetch(:mode, :single)
      overrides.delete(:mode)
      @config = SimpleSsh.configuration.to_h(overrides)
    end

    # Execute an SSH command against the remote host.
    #
    def !(*commands)
      options  = commands.last.is_a?(Hash) ? commands.pop : {}

      commands = @command_chain.clone if chain? || pipe?
      commands.unshift("cd #{options[:base_path]}") if options[:base_path]

      ssh_command = ssh_command(commands, config)

      log(:info, "SimpleSsh Execute: #{ssh_command}")

      if options.fetch(:interactive, false)
        return `#{ssh_command}`
      else
        return system(ssh_command)
      end
    end


    # Generate a command to exec in the remote shell.  This process will
    # either add the command to the command chain (if it's in pipe or chain
    # execution mode) or directly exec the command (if it's in single
    # execution mode)
    #
    # @overload sh(command, *args) [single execution mode]
    #   @param command [String] The remote command to call
    #   @param args [Array] An array of arguments to pass to the command.
    #
    #   @return [String] The results of the SSH execution
    #
    # @overload sh(command, *args) [chain|pipe execution mode]
    #   @param command [String] The remote command to call
    #   @param args [Array] An array of arguments to pass to the command.
    #
    #   @return [SimpleSsh::Ssh] A reference to the SSH instance so additional calls can be added.
    #
    def sh(*args)
      puts "args: #{args}"
      options     = !args.nil? ? (args.last.is_a?(Hash) ? args.pop : {}) : {}
      ssh_command = args.join(" ")

      if @execution_mode == :chain || @execution_mode == :pipe
        add_command(ssh_command)
        return self
      else
        return self.!(ssh_command, options)
      end
    end

    # Adds a command to the command chain.
    #
    # @param command [String] The command to add to the command chain
    #
    def add_command(command)
      @command_chain ||= []
      @command_chain << command
    end

    # Clears out the command chain.
    #
    def clear_commands()
      @command_chain = nil
    end

    # Turn any previously undefined method call into a shell command.
    #
    def method_missing(method, *args)
      args.unshift(method.to_s)
      return sh(*args)
    end

    # Generates the full SSH command to execute on a single command or an array
    # of commands
    #
    # @overload ssh_command(command, overrrides={})
    #   @param command [String] The command to execute through SSH
    #   @param overrides [Hash] A hash of configuration values to override.
    #
    # @overload ssh_command(commands, overrides={})
    #   @param commands [Array<String>] An array of commands to execute through SSH
    #   @param overrides [Hash] A hash of configuration values to override.
    #
    #
    def ssh_command(commands, overrides={})
      config        = SimpleSsh.configuration.to_h(overrides)
      commands      = [ commands ] if commands.is_a?(String)
      "#{config[:binary_path]} #{param_string(config)} #{config[:user]}@#{config[:hostname]} '#{remote_shell_command(commands, config)}'"
    end

    # Generates the remote shell command based on a single command or an array
    # of commands
    #
    # @overload remote_shell_command(command, overrrides={})
    #   @param command [String] The command to execute in the bash shell
    #   @param overrides [Hash] A hash of configuration values to override.
    #
    # @overload remote_shell_command(commands, overrides={})
    #   @param commands [Array<String>] An array of commands to execute in the bash shell
    #   @param overrides [Hash] A hash of configuration values to override.
    #
    def remote_shell_command(commands, overrides={})
      config        = SimpleSsh.configuration.to_h(overrides)
      commands      = [ commands ] if commands.is_a?(String)
      sh_command    = commands.join(command_join_string)
      return sh_command if (config[:remote_shell].nil? || config[:remote_shell].length == 0)
      return "#{config[:remote_shell]} -l -c \"#{sh_command}\""
    end


    # Generates the SSH parameter string for the SSH command
    #
    # @param overrides [Hash] A hash of values to override in the final param string.
    #
    # @return [String] The string of SSH params.
    #
    def param_string(overrides={})
      config = SimpleSsh.configuration.to_h(overrides)
      options = config[:config_options].map{ |k,v| "-o #{k}=#{v}" } if config[:config_options]

      params = []
      params << "-A"                                if config[:agent_forwarding]
      params << "-C"                                if config[:compress_data]
      params << "-F #{config[:config_file].to_s}"   if config[:config_file]
      params << options                             if config[:config_options]
      params << "-i #{config[:identity_file].to_s}" if config[:identity_file]
      params << "-4"                                if config[:ip_v4]
      params << "-6"                                if config[:ip_v6]
      params << "-E #{config[:log_file].to_s}"      if config[:log_file]
      params << "-t"                                if config[:psuedo_terminal]
      params << "-q"                                if config[:quiet]
      params << "-1"                                if config[:version_1]
      params << "-2"                                if config[:version_2]

      params.join(" ")
    end

    # Generates the join string used to join multiple shell commands based on
    # the current execution mode.
    #
    # @return [String] The command join string
    #
    def command_join_string
      pipe? ? " | " : " && "
    end

    # Set the SSH execution into single mode, so calls will be executed as
    # individual SSH sessions
    #
    def single
      @execution_mode = :single
      clear_commands
      return self
    end

    # Determine if the execution mode is :single
    #
    # @return [Boolean] An indication that the execution mode is currently :single
    #
    def single?
      @execution_mode == :single
    end

    # Set the SSH execution into chain mode, so all calls will be executed
    # inside one SSH session as a chain of commands.
    #
    def chain
      new_config        = @config.clone
      new_config[:mode] = :chain
      return self.class.new(new_config)
    end

    # Determine if the execution mode is :chain
    #
    def chain?
      @execution_mode == :chain
    end

    # Set the SSH execution into pipe mode, so all calls will be executed
    # inside one SSH session as a pipeline of commands.
    #
    def pipe
      new_config        = @config.clone
      new_config[:mode] = :pipe
      return self.class.new(new_config)
    end

    # Determine if the execution mode is :pipe
    #
    def pipe?
      @execution_mode == :pipe
    end

    # Log a message to the logger
    #
    # @param level [Symbol] The logging level of the message
    # @param message [String] The message to log
    #
    def log(level, message)
      return if SimpleSsh.configuration.logger.nil?
      SimpleSsh.configuration.logger.send(level, message)
    end

  end
end

require 'colorize'

module SimpleSsh
  class Ssh

    # @attr [Symbol] The mode of the SSH execution.  Can be :single, :chain or :pipe
    attr_reader :execution_mode

    # @attr [Hash] The current configuration of this SSH instance.
    attr_reader :config

    def initialize(overrides={})
      overrides.delete(:mode)
      @config = SimpleSsh.configuration.to_h(overrides)
    end

    # Execute an SSH command against the remote host.
    #
    def !(*commands)
      options  = commands.last.is_a?(Hash) ? commands.pop : {}

      commands.unshift("cd #{options[:base_path]}") if options[:base_path]

      ssh_command = ssh_command(commands, config)

      log(:info, ssh_command)

      clear_inject

      if options.fetch(:interactive, false)
        return system(ssh_command)
      else
        return `#{ssh_command}`
      end
    end

    # Pipelines the results of a command into the SSH call.
    #
    def inject(command)
      @inject ||= []
      @inject << command
      return self
    end

    # Clears the inject stack
    #
    def clear_inject
      @inject = nil
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
      ssh_commands  = []
      ssh_commands  << @inject.join(" | ") if (@inject && @inject.length > 0)
      ssh_commands  << "#{config[:binary_path]} #{param_string(config)} #{config[:user]}@#{config[:hostname]} '#{remote_shell_command(commands, config)}'"
      ssh_commands.join(" | ")
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
    # @overload remote_shell_command(commands, overrides={})
    #   @param commands [SimpleSsh::Commands] A commands object
    #   @param overrides [Hash] A hash of configuration values to override.
    #
    def remote_shell_command(commands, overrides={})
      commands  = Commands.new(commands: commands) if commands.is_a?(Array)
      config    = SimpleSsh.configuration.to_h(overrides)

      return commands.to_s if (config[:remote_shell].nil? || config[:remote_shell].length == 0)
      return "#{config[:remote_shell]} -l -c \"#{commands.to_s}\""
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

    # Execute a block of commands in chain mode
    #
    def chain(&block)
      commands = Commands.new(mode: :chain)
      commands.instance_eval(&block)
      self.!(commands)
    end

    # Set the SSH execution into pipe mode, so all calls will be executed
    # inside one SSH session as a pipeline of commands.
    #
    def pipe(&block)
      cmds = Commands.new(mode: :pipe)
      cmds.instance_eval(&block)
      self.!(cmds.to_a)
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

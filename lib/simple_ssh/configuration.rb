require 'simple_ssh/loggers/default'

module SimpleSsh

  # A class to setup global configurations for Simple SSH.  These configurations
  # are based on the BSD SSH commands.
  #
  class Configuration

    # @attr [Boolean] (false) <ssh -Aa> Enables/disables forwarding of the authentication agent connection.
    attr_accessor :agent_forwarding

    # @attr [String] (nil) <ssh -c> Selects the cipher specification for encrypting the session. For Protocol V1, this can be a single value ("3des","blowfish","des").  For Protocol V2, this can be a comma separated string of ciphers listed in order of preference.
    attr_accessor :cipher_spec

    # @attr [String] ("ssh") The path to the SSH binary on the machine executing the commands.
    attr_accessor :binary_path

    # @attr [Boolean] (false) <ssh -C> Requests compression of all data (including stdin, stdout, stderr, and data for forwarded X11, TCP and UNIX-domain connections).
    attr_accessor :compress_data

    # @attr [String] (nil) <ssh -F> Specifies an alternative per-user configuration file.  If a configuration file is given the system-wide configuration file will be ignored.
    attr_accessor :config_file

    # @attr [Hash] ({ "UserKnownHostsFile" => "/dev/null", "StrictHostKeyChecking" => "no" }) <ssh -o key=value> Can be used to give options in the format used in the configuration file.  The default options allow the SSH commands to execute without user interaction, particularly when a hostname is not known.
    attr_accessor :config_options

    # @attr [String] (nil) <ssh @hostname> Specifies the hostname of the remote machine.
    attr_accessor :hostname

    # @attr [String] (nil) <ssh -i> Selects a file from which the identity (private key) for public key authentication is read.  The default is "~/.ssh/identity" for Protocol V1, and "~/.ssh/id_dsa", "~/.ssh/id_ecdsa", "~/.ssh/id_ed25519" and "~/.ssh/id_rsa" for Protocol V2.
    attr_accessor :identity_file

    # @attr [Boolean] (false) <ssh -4> Use IP V4 addresses only
    attr_accessor :ip_v4

    # @attr [Boolean] (false) <ssh -6> Use IP V6 addresses only. When set, this overrides the :ip_v4 configuration
    attr_accessor :ip_v6

    # @attr [String] (nil) <ssh -E> Append debug logs to :log_file instead of standard error.
    attr_accessor :log_file

    # @attr [Logger] (SimpleSsh::DefaultLogger) A logger to output information during SSH execution.  The logger should define #debug, #info, #warn & #error methods.
    attr_accessor :logger

    # @attr [Boolean] (true) <ssh -t> Psuedo-terminal allocation.
    attr_accessor :psuedo_terminal

    # @attr [Boolean] (true) <ssh -q> Quiet mode. Suppresses most warnings and diagnostic messages.
    attr_accessor :quiet

    # @attr [String] ("bash") Determine which Unix shell to execute commands under on the remote machine.
    attr_accessor :remote_shell

    # @attr [String] (nil) <ssh user> Specifies the user to log in as on the remote machine.
    attr_accessor :user

    # @attr [Boolean] (false) <ssh -1> Use protocol version 1 only
    attr_accessor :version_1

    # @attr [Boolean] (true) <ssh -2> Use protocol version 2 only. When set, this overrides the :version_1 configuration.
    attr_accessor :version_2

    # Initializes the configuration with the default settings
    #
    def initialize
      @agent_forwarding   = false
      @binary_path        = "ssh"
      @compress_data      = false
      @config_file        = nil
      @config_options     = { "UserKnownHostsFile" => "/dev/null", "StrictHostKeyChecking" => "no" }
      @cipher_spec        = nil
      @hostname           = nil
      @identity_file      = nil
      @ip_v4              = false
      @ip_v6              = false
      @log_file           = nil
      @logger             = Loggers::Default.new
      @psuedo_terminal    = true
      @quiet              = true
      @remote_shell       = "bash"
      @user               = nil
      @version_1          = false
      @version_2          = true
    end

    # Generate a Hash of the configuration values
    #
    # @param [Hash] overrides A hash of values to override in the final configuration hash.
    #
    # @return [Hash] A Hash of configuration values
    #
    def to_h(overrides={})
      h = {}
      configs = self.instance_variables.map{ |v| v.to_s.gsub("@","").to_sym }
      configs.each{ |c| h[c] = self.send(c) }
      o = overrides.clone
      invalid_overrides = (o.keys - configs)
      invalid_overrides.each{ |io| o.delete(io) }
      h.merge!(o)
      h
    end
  end
end

require "simple_ssh/version"
require "simple_ssh/configuration"
require "simple_ssh/commands"
require "simple_ssh/ssh"
require "simple_ssh/loggers/default"
require "simple_ssh/loggers/file_path"

module SimpleSsh

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= SimpleSsh::Configuration.new
  end

  def self.configure
    yield(configuration)
  end


  def self.!(commands, config={})
    Ssh.new(config).!(commands, config)
  end

  def self.chain(config={}, &block)
    Ssh.new(config).chain(&block)
  end

  def self.pipe(config={}, &block)
    Ssh.new(config).pipe(&block)
  end

  def self.inject(command, config={})
    Ssh.new(config).inject(command)
  end
end

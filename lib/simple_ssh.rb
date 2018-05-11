require "simple_ssh/version"
require "simple_ssh/configuration"
require "simple_ssh/ssh"
require "simple_ssh/loggers/default"

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

  def self.chain(config={})
    Ssh.new(config).chain
  end

  def self.pipe(config={})
    Ssh.new(config).pipe
  end
end

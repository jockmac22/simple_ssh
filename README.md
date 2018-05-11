# Simple SSH

Simple SSH is an easy to use SSH tool for Ruby.  This gem allows you quickly and easily execute commands on a remote server.

The primary features are:
1. Global configuration
3. Execute individual commands on the remote machine.
4. Execute chained commands on the remote machine.
5. Execute command pipelines on the remote machine.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_ssh', git: "git@github.com:jockmac22/simple_ssh.git"
```

And then execute:

    $ bundle

<!-- Or install it yourself as:

    $ gem install simple_ssh -->

## SSH Authentication

SSH doesn't allow passwords to be transacted in the requests (at least not
easily), so you will have to make sure that you have access to the remote
machine using an SSH key.  

Here's a tutorial on how to configure users using an SSH key on a Linux Server:
https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server

## Global Configuration

Simple SSH uses a standard Ruby configuration pattern, which makes global
configuration easy.

#### The basic configuration

To configure Simple SSH you call the `SimpleSsh.configure` block like this:

```ruby
require 'simple_ssh'

SimpleSsh.configure do |c|
  # Enables/disables forwarding of the authentication agent connection.
  # Default: false
  c.agent_forwarding  = false                

  # Selects the cipher specification for encrypting the session. For Protocol
  # V1, this can be a single value ("3des","blowfish","des").  For Protocol V2,
  # this can be a comma separated string of ciphers listed in order of
  # preference.
  # Default: nil
  c.cipher_spec       = "3des,blowfish,des"   

  # The path to the SSH binary on the machine executing the commands.
  # Default: "ssh"
  c.binary_path       = "ssh"                       

  # Requests compression of all data (including stdin, stdout, stderr, and data for forwarded X11, TCP and UNIX-domain connections).
  # Default: false
  c.compress_data     = false                     

  # Specifies an alternative per-user configuration file.  If a configuration file is given the system-wide configuration file will be ignored.
  # Default: nil
  c.config_file       = "/tmp/ssh_config_file"      


  # Can be used to give options in the format used in the configuration file.  The default options allow the SSH commands to execute without user interaction, particularly when a hostname is not known.
  # Default: { "UserKnownHostsFile" => "/dev/null", "StrictHostKeyChecking" => "no" }
  c.config_options    = {
    "UserKnownHostsFile"    => "/dev/null",
    "StrictHostKeyChecking" => "no"
  }

  # Specifies the hostname of the remote machine.
  # Default: nil
  c.hostname          = "simplessh.freeshells.org"

  # Selects a file from which the identity (private key) for public key
  # authentication is read.  The default is "~/.ssh/identity" for Protocol V1,
  # and "~/.ssh/id_dsa", "~/.ssh/id_ecdsa", "~/.ssh/id_ed25519" and
  # "~/.ssh/id_rsa" for Protocol V2.
  # Default: nil
  c.identity_file     = "/home/user/.ssh/id_rsa"

  # Use IP V4 addresses only
  # Default: false
  c.ip_v4             = false

  # Use IP V6 addresses only. When set, this overrides the :ip_v4 configuration
  # Default: false
  c.ip_v6             = false

  # Append debug logs to :log_file instead of standard error.
  # Default: nil
  c.log_file          = "/var/log/simple_ssh.log"

  # A logger to output information during SSH execution.  The logger should
  # define #debug, #info, #warn & #error methods.
  # Default: SimpleSsh::Loggers::Default
  c.logger            = Rails.logger

  # Psuedo-terminal allocation.
  # Default: true
  c.psuedo_terminal   = false

  # Quiet mode. Suppresses most warnings and diagnostic messages.
  # Default: true
  c.quiet             = false

  # Determine which Unix shell to execute commands under on the remote machine.
  # Default: "bash"
  c.remote_shell      = "/bin/bash"

  # Specifies the user to log in as on the remote machine.
  # Default: nil
  c.user              = "fs-simpless"

  # Use protocol version 1 only
  # Default: false
  c.version_1         = false

  # Use protocol version 2 only. When set, this overrides the :version_1
  # configuration.
  # Default: true
  c.version_2         = true
end
```

### Configuring for Rails

Global configuration for Rails is also easy.  Add an file to your
`config/intializers/` folder called `simple_ssh.rb`.  Add a configuration to the
file similar to the example above (with your appropriate configurations of
course).


## Execute Individual Commands

Executing a single command is easy. Just send the command like this:

```ruby
SimpleSsh.!("ls -alF", user: "fs-simpless", hostname: "simplessh.freeshells.org")
```

This will execute the `ls -alF` command on the remote machine, using the user
and hostname provided, and return the contents of the request as a string.

If you already have the user and hostname setup in the Global Configuration, then
all you need to do is this:

```ruby
SimpleSsh.!("ls -alF")
```

The bang (!) method indicates that the SSH command is being executed.

## Execute chained commands

Bash shells allow you to chain commands together using "&&" between each
command.

Simple SSH allows you to intuitively generate a list of commands and then
execute them using command chains.

The `chain` method interprets subsequent method calls as shell commands
(assuming they don't already have a predefined function), so you can use
dot-notation to execute commands in sequence.

This example will change directories and get a list of files:
```ruby
SimpleSsh.chain.
  cd("/home/user").
  ls("-alF").
  !
```

*NOTE:* The bang (!) at the end is important, it tells Simple SSH to execute the
chain of commands.

This is the equivalent of executing the following command from the remote shell:
```bash
cd /home/user && ls -alF
```

### Chaining Commands with Paths or Special Characters

If you have a shell command that has a command path, or special characters that
don't play nicely with ruby, you can still chain them using the `sh()` method:

```ruby
SimpleSsh.chain.
  cd("/home/user").
  sh("/path/to/some-command-that-doesnt-play-well.sh -with -ruby")
  !
```

## Execute pipeline commands

Bash shells allow you to pipeline commands using "|" between each command.

Simple SSH allows you to intuitively generate a list of commands and then
execute them as a pipeline.

The `pipe` method interprets subsequent method calls as shell commands (assuming
they don't already have a predefined function), so you can use dot-notation to
execute commands together as a pipeline.

This example will return a list of applications currently running with Ruby:
```ruby
SimpleSsh.pipe.
  ps("-ax").
  grep("'ruby'").
  !
```

This is the equivalent of executing the following command from the remote shell:
```bash
ps -ax | grep 'ruby'
```

*NOTE:* The bang (!) at the end is important, it tells Simple SSH to execute the
pipeline of commands.

### Pipelining Commands with Paths or Special Characters

If you have a shell command that has a command path, or special characters that
don't play nicely with ruby, you can still pipeline them using the `sh()`
method:

```ruby
SimpleSsh.pipe.
  ps("-ax").
  sh("/path/to/some-command-that-doesnt-play-well.sh -with -ruby")
  !
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jockmac22/simple_ssh. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SimpleSsh project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/simple_ssh/blob/master/CODE_OF_CONDUCT.md).

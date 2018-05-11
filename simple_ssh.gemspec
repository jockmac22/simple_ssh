
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "simple_ssh/version"

Gem::Specification.new do |spec|
  spec.name          = "simple_ssh"
  spec.version       = SimpleSsh::VERSION
  spec.authors       = ["Jocko"]
  spec.email         = ["jocko.macgregor@wowza.com"]

  spec.summary       = %q{A simple, Ruby based SSH tool. Execute commands easily on remote machines.}
  spec.description   = %q{Simple SSH allows you to access remote machines and execute shell commands easily, and with few limitations. You can execute one-off calls, chain commands together for single execution, or even use pipes to generate command output. }
  spec.homepage      = "https://github.com/jockmac22/simple_ssh"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "colorize"
end

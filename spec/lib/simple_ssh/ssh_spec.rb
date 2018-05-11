require "spec_helper"

module SimpleSsh
  RSpec.describe Ssh do

    describe "#param_string" do
      it "can generate a default param string" do
        expect(Ssh.new.param_string).to eq("-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -q -2")
      end

      it "can generate a param string based on override values" do
        overrides = {
          agent_forwarding: true,
          config_file:      "/tmp/configfile",
          config_options:   {
            "AddKeysToAgent" => "on",
            "CanonicalDomains" => "abc.com,cde.com"
          },
          ip_v6:            true
        }
        expect(Ssh.new.param_string(overrides)).to eq("-A -F /tmp/configfile -o AddKeysToAgent=on -o CanonicalDomains=abc.com,cde.com -6 -t -q -2")
      end

    end

    describe "#remote_shell_command" do

      it "can generate a remote shell command from a string" do
        expect(Ssh.new.remote_shell_command("cat somefile")).to eq("bash -l -c \"cat somefile\"")
      end

      it "can generate a remote shell command from a string with a configuration override" do
        overrides = {
          remote_shell: "/bin/bash"
        }
        expect(Ssh.new.remote_shell_command("cat somefile", overrides)).to eq("/bin/bash -l -c \"cat somefile\"")
      end

      it "can generate a chained remote shell command from an array of strings a configuration override" do
        commands = [
          "cat somefile",
          "grep 'someword'"
        ]
        overrides = {
          remote_shell: "/bin/bash"
        }
        expect(Ssh.new.remote_shell_command(commands, overrides)).to eq("/bin/bash -l -c \"cat somefile && grep 'someword'\"")
      end

    end

    describe "#ssh_command" do

      it "can generate a complete SSH command from a single command string" do
        expect(Ssh.new.ssh_command("cat somefile")).to eq("ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -q -2 @ 'bash -l -c \"cat somefile\"'")
      end

      it "can generate a complete SSH command from a single command string with a configuration override" do
        overrides = {
          user:         "ubuntu",
          hostname:     "somesite.com",
          remote_shell: "/bin/bash"
        }
        expect(Ssh.new.ssh_command("cat somefile", overrides)).to eq("ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -q -2 ubuntu@somesite.com '/bin/bash -l -c \"cat somefile\"'")
      end

      it "can generate a chained remote shell command from an array of strings" do
        commands = [
          "cat somefile",
          "grep 'someword'"
        ]
        expect(Ssh.new.remote_shell_command(commands)).to eq("bash -l -c \"cat somefile && grep 'someword'\"")
      end

      it "can generate a complete chained SSH command from an array of command strings" do
        commands = [
          "cat somefile",
          "grep 'someword'"
        ]
        expect(Ssh.new.ssh_command(commands)).to eq("ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -q -2 @ 'bash -l -c \"cat somefile && grep 'someword'\"'")
      end

      it "can generate a complete chained SSH command from an array of command strings with a configuration override" do
        commands = [
          "cat somefile",
          "grep 'someword'"
        ]
        overrides = {
          user:         "ubuntu",
          hostname:     "somehost.com",
          binary_path:  "/bin/ssh",
          remote_shell: "/bin/bash"
        }
        expect(Ssh.new.ssh_command(commands, overrides)).to eq("/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -q -2 ubuntu@somehost.com '/bin/bash -l -c \"cat somefile && grep 'someword'\"'")
      end


    end

  end
end

require "spec_helper"

module SimpleSsh
  RSpec.describe Configuration do

    describe "#version_1" do
      it "has a default value of false" do
        expect(Configuration.new.version_1).to be_falsey
      end

      it "can set a value" do
        config = Configuration.new
        expect{ config.version_1 = true }.not_to raise_exception(Exception)
        expect(config.version_1).to eq(true)
      end
    end

    describe "#version_2" do
      it "has a default value of true" do
        expect(Configuration.new.version_2).to be_truthy
      end

      it "can set a value" do
        config = Configuration.new
        expect{ config.version_2 = false }.not_to raise_exception(Exception)
        expect(config.version_2).to eq(false)
      end
    end

    describe "#ip_v4" do
      it "has a default value of false" do
        expect(Configuration.new.ip_v4).to be_falsey
      end

      it "can set a value" do
        config = Configuration.new
        expect{ config.ip_v4 = true }.not_to raise_exception(Exception)
        expect(config.ip_v4).to eq(true)
      end
    end

    describe "#ip_v6" do
      it "has a default value of false" do
        expect(Configuration.new.ip_v6).to be_falsey
      end

      it "can set a value" do
        config = Configuration.new
        expect{ config.ip_v6 = true }.not_to raise_exception(Exception)
        expect(config.ip_v6).to eq(true)
      end
    end

    describe "#agent_forwarding" do
      it "has a default value of false" do
        expect(Configuration.new.agent_forwarding).to be_falsey
      end

      it "can set a value" do
        config = Configuration.new
        expect{ config.agent_forwarding = true }.not_to raise_exception(Exception)
        expect(config.agent_forwarding).to eq(true)
      end
    end

    describe "#compress_data" do
      it "has a default value of false" do
        expect(Configuration.new.compress_data).to be_falsey
      end

      it "can set a value" do
        config = Configuration.new
        expect{ config.compress_data = true }.not_to raise_exception(Exception)
        expect(config.compress_data).to eq(true)
      end
    end

    describe "#cipher_spec" do
      it "has a default value of nil" do
        expect(Configuration.new.cipher_spec).to be_nil
      end

      it "can set a value" do
        config = Configuration.new
        expect{ config.cipher_spec = "blowfish" }.not_to raise_exception(Exception)
        expect(config.cipher_spec).to eq("blowfish")
      end
    end

    describe "#log_file" do
      it "has a default value of nil" do
        expect(Configuration.new.log_file).to be_nil
      end

      it "can set a value" do
        config = Configuration.new
        expect{ config.log_file = "/tmp/logfile" }.not_to raise_exception(Exception)
        expect(config.log_file).to eq("/tmp/logfile")
      end
    end

    describe "#config_file" do
      it "has a default value of nil" do
        expect(Configuration.new.config_file).to be_nil
      end

      it "can set a value" do
        config = Configuration.new
        expect{ config.config_file = "/tmp/configfile" }.not_to raise_exception(Exception)
        expect(config.config_file).to eq("/tmp/configfile")
      end
    end

    describe "#identity_file" do
      it "has a default value of nil" do
        expect(Configuration.new.identity_file).to be_nil
      end

      it "can set a value" do
        config = Configuration.new
        expect{ config.identity_file = "/tmp/identityfile" }.not_to raise_exception(Exception)
        expect(config.identity_file).to eq("/tmp/identityfile")
      end
    end

    describe "#user" do
      it "has a default value of nil" do
        expect(Configuration.new.user).to be_nil
      end

      it "can set a value" do
        config = Configuration.new
        expect{ config.user = "username" }.not_to raise_exception(Exception)
        expect(config.user).to eq("username")
      end
    end

    describe "#hostname" do
      it "has a default value of nil" do
        expect(Configuration.new.hostname).to be_nil
      end

      it "can set a value" do
        config = Configuration.new
        expect{ config.hostname = "test.com" }.not_to raise_exception(Exception)
        expect(config.hostname).to eq("test.com")
      end
    end

    describe "#to_h" do
      it "can generate a hash of configuration values" do
        hsh = Configuration.new.to_h
        expect(hsh).to be_a(Hash)
        expect(hsh.has_key?(:version_1)).to be_truthy
        expect(hsh.has_key?(:version_1)).to be_truthy
        expect(hsh.has_key?(:version_2)).to be_truthy
        expect(hsh.has_key?(:ip_v4)).to be_truthy
        expect(hsh.has_key?(:ip_v6)).to be_truthy
        expect(hsh.has_key?(:agent_forwarding)).to be_truthy
        expect(hsh.has_key?(:compress_data)).to be_truthy
        expect(hsh.has_key?(:cipher_spec)).to be_truthy
        expect(hsh.has_key?(:log_file)).to be_truthy
        expect(hsh.has_key?(:config_file)).to be_truthy
        expect(hsh.has_key?(:identity_file)).to be_truthy
        expect(hsh.has_key?(:user)).to be_truthy
        expect(hsh.has_key?(:hostname)).to be_truthy
        expect(hsh.has_key?(:not_config)).to be_falsey
      end

      it "can generate a hash of configuration values with override values applied" do
        hsh = Configuration.new.to_h({ log_file: "/tmp/logfile", user: "someuser" })
        expect(hsh).to be_a(Hash)
        expect(hsh.has_key?(:version_1)).to be_truthy
        expect(hsh.has_key?(:version_1)).to be_truthy
        expect(hsh.has_key?(:version_2)).to be_truthy
        expect(hsh.has_key?(:ip_v4)).to be_truthy
        expect(hsh.has_key?(:ip_v6)).to be_truthy
        expect(hsh.has_key?(:agent_forwarding)).to be_truthy
        expect(hsh.has_key?(:compress_data)).to be_truthy
        expect(hsh.has_key?(:cipher_spec)).to be_truthy
        expect(hsh.has_key?(:log_file)).to be_truthy
        expect(hsh.has_key?(:config_file)).to be_truthy
        expect(hsh.has_key?(:identity_file)).to be_truthy
        expect(hsh.has_key?(:user)).to be_truthy
        expect(hsh.has_key?(:hostname)).to be_truthy
        expect(hsh.has_key?(:not_config)).to be_falsey

        expect(hsh[:log_file]).to eq("/tmp/logfile")
        expect(hsh[:user]).to eq("someuser")
      end

    end
  end
end

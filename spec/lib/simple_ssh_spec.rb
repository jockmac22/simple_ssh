RSpec.describe SimpleSsh do

  describe "#VERSION" do
    it "has a version number" do
      expect(SimpleSsh::VERSION).not_to be nil
    end
  end
  
  describe "#configuration" do

    it "has an accessible configuration" do
      config = nil
      expect{ config = SimpleSsh.configuration }.not_to raise_exception(Exception)
      expect(config).to be_a(SimpleSsh::Configuration)
    end

    it "has a default configuration" do
      config = SimpleSsh.configuration
      expect(config.version_1).to be_falsey
    end

  end

  describe "#configure" do

    it "can set a global configuration" do
      SimpleSsh.configure do |config|
        config.version_1    = true
        config.version_2    = false
        config.log_file     = "/tmp/logfile"
      end

      expect(SimpleSsh.configuration.version_1).to be_truthy
      expect(SimpleSsh.configuration.version_2).to be_falsey
      expect(SimpleSsh.configuration.log_file).to eq("/tmp/logfile")
    end

  end
end

require 'moolah'

describe Moolah do
  describe ".api_key" do
    it "has default values" do
      expect(Moolah.send(:api_key)).to eq(nil)
      expect(Moolah.send(:api_secret)).to eq(nil)
      expect(Moolah.send(:endpoint)).to eq("https://api.moolah.io/v2")
    end
  end

  describe ".configure" do
    it "allows api_key configuration via a block" do
      sample_api_key = "12345678"
      Moolah.configure do |config|
        config.api_key = sample_api_key
      end

      expect(Moolah.api_key).to eq(sample_api_key)
    end

    it "allows endpoint configuration via a block" do
      sample_endpoint = "http://example.com"
      Moolah.configure do |config|
        config.endpoint = sample_endpoint
      end

      expect(Moolah.endpoint).to eq(sample_endpoint)
    end
  end
end

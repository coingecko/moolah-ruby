require 'moolah'

describe Moolah do
  describe ".api_key" do
    it "has default values" do
      expect(Moolah.send(:api_key)).to eq(nil)
      expect(Moolah.send(:api_secret)).to eq(nil)
      expect(Moolah.send(:endpoint)).to eq("https://api.moolah.io")
    end
  end

  describe ".configure" do
    it "allows configuration via block" do
      sample_api_key = "1234567890"
      sample_api_secret = "secret"
      sample_endpoint = "http://example.com"

      Moolah.configure do |config|
        config.api_key = sample_api_key
        config.api_secret = sample_api_secret
        config.endpoint = sample_endpoint
      end

      expect(Moolah.api_key).to eq(sample_api_key)
      expect(Moolah.api_secret).to eq(sample_api_secret)
      expect(Moolah.endpoint).to eq(sample_endpoint)
    end
  end
end

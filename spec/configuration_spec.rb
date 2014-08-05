require 'moolah'

describe Moolah do
  describe ".configure" do
    it "allows api_key to be configured" do
      expect(Moolah.send(:api_key)).to eq(nil)
    end

    it "allows endpoint to be configured" do
      expect(Moolah.send(:endpoint)).to eq("https://api.moolah.io/v2")
    end
  end
end

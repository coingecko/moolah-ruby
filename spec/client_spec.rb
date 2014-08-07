require 'moolah'

describe Moolah::Client do
  it "complains when API key is not configured" do
    expect { Moolah::Client.new }.to raise_error(ArgumentError)
  end

  context "with API key" do
    before do
      allow(Moolah).to receive(:api_key).and_return("1234567890")
    end

    it "should not complain if API key is given" do
      expect { Moolah::Client.new }.not_to raise_error
    end

    it "can take api_secret and ipn as optional parameters" do
      client = Moolah::Client.new({ ipn: "http://www.example.com", api_secret: "a_secret_key" })
      expect(client.ipn).to eq("http://www.example.com")
      expect(client.api_secret).to eq("a_secret_key")
    end 
  end
end

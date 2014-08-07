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
  end
end

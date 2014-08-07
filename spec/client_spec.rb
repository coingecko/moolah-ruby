require 'moolah'

describe Moolah::Client do

  describe ".initialize" do
    it "complains when API key is not configured" do
      expect { Moolah::Client.new }.to raise_error(ArgumentError)
    end

    context "with API key" do
      before do
        allow(Moolah).to receive(:api_key).and_return("1234567890")
      end

      it "should not complain if API key is given" do
        expect(Moolah::api_key).to eq("1234567890")
        expect { Moolah::Client.new }.not_to raise_error
      end

      it "can take api_secret and ipn as optional parameters" do
        client = Moolah::Client.new({ ipn: "http://www.example.com", api_secret: "a_secret_key" })
        expect(client.ipn).to eq("http://www.example.com")
        expect(client.api_secret).to eq("a_secret_key")
      end
    end
  end

  describe ".create_transaction" do
    let(:action_path) { "/private/merchant/create" }
    let(:client) { Moolah::Client.new }

    # Provide API Key first
    before do
      allow(Moolah).to receive(:api_key).and_return("1234567890")

      # Stub the connection
      test_connection = Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.post(action_path) { |env| [ 200, {}, 'hello' ]}
        end
      end
      allow(client).to receive(:connection).and_return(test_connection)
    end

    it "allows transaction params to be given as argument" do
      transaction_params = { coin: "dogecoin", amount: "1234", currency: "USD", product: "Coingecko Pro" }
      transaction = client.create_transaction transaction_params
      expect(transaction.coin).to eq("dogecoin")
    end
  end

end

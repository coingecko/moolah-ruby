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

      it "allows passing of optional fields" do 
        client = Moolah::Client.new({ api_secret: "secret", ipn: "www.example.com/processed_payment" })
        expect(client.api_secret).to eq("secret")
        expect(client.ipn).to eq("www.example.com/processed_payment")
      end
    end
  end

  describe ".create_transaction" do
    let(:action_path) { "/private/merchant/create" }
    let(:transaction_params) { { coin: "dogecoin", amount: "1234", currency: "USD", product: "Coingecko Pro" } }
    let(:request_stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post(action_path) { |env| [ 200, {}, 'hello' ]}
      end
    end
    let (:test_connection) do
      Faraday.new do |builder|
        builder.adapter :test, request_stubs
      end
    end

    # Provide API Key first
    before do
      allow(Moolah).to receive(:api_key).and_return("1234567890")
    end

    context "without optional parameters (ipn, api_secret, ipn_extra)" do
      let(:client) { Moolah::Client.new }
      
      before do
        allow(client).to receive(:connection).and_return(test_connection)
      end

      it "allows transaction params to be given as argument" do
        transaction = client.create_transaction transaction_params
        expect(transaction.coin).to eq("dogecoin")
      end

      it "allows transaction params to be given in the block" do
        transaction = client.create_transaction do |t|
          t.coin = "dogecoin"
          t.currency = "USD"
          t.amount = "123"
          t.product = "Coingecko Pro"
        end
        expect(transaction.product).to eq("Coingecko Pro")
      end
    end

    context "with optional parameters" do
      let(:client) { Moolah::Client.new({ api_secret: "secret", ipn: "www.example.com/processed_payment" }) }
      before do
        allow(client).to receive(:connection).and_return(test_connection)
      end

      it "sends out request with these optional parameters" do
        transaction = client.create_transaction transaction_params
        expect(transaction.coin).to eq("dogecoin")
      end
    end
  end

end

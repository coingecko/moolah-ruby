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
    let(:transaction_params) { { coin: "dogecoin", amount: "20", currency: "USD", product: "Coingecko Pro" } }
    let(:request_stubs) { Faraday::Adapter::Test::Stubs.new }
    let (:test_connection) do
      Faraday.new do |builder|
        builder.adapter :test, request_stubs
      end
    end

    # Provide API Key first
    before do
      allow(Moolah).to receive(:api_key).and_return("1234567890")
    end

    shared_examples :success_transaction do
      it { expect(transaction.response).to be_an_instance_of(Moolah::TransactionResponse) }
      it { expect(transaction.response.status).to eq("success") }
      it { expect(transaction.response.amount).to eq("121526.39285714") }
      it { expect(transaction.response.coin).to eq("dogecoin") }
      it { expect(transaction.response.guid).to eq("a4dc89fcc-8ad-3f4c1bf529-6396c1acc4-") }
      it { expect(transaction.response.address).to eq("DS6frMZR5jFVEf9V6pBi9qtcVJa2JX5ewR") }
      it { expect(transaction.response.timestamp).to eq(1407579569) }
      it { expect(transaction.response.url).to eq("https://pay.moolah.io/a4dc89fcc-8ad-3f4c1bf529-6396c1acc4-") }
    end

    shared_examples :failure_transaction do
      it { expect(transaction.response).to be_an_instance_of(Moolah::TransactionResponse) }
      it { expect(transaction.response.status).to eq("failure") }
      it { expect(transaction.response.amount).to eq(nil) }
      it { expect(transaction.response.coin).to eq(nil) }
      it { expect(transaction.response.guid).to eq(nil) }
      it { expect(transaction.response.address).to eq(nil) }
      it { expect(transaction.response.timestamp).to eq(nil) }
      it { expect(transaction.response.url).to eq(nil) }
    end

    context "successful transaction" do
      context "without optional parameters (ipn, api_secret, ipn_extra)" do
        let(:client) { Moolah::Client.new }
        let(:post_path) { "#{action_path}?amount=20&apiKey=1234567890&coin=dogecoin&currency=USD&product=Coingecko+Pro" }
        let(:json_response) { '{"status":"success","guid":"a4dc89fcc-8ad-3f4c1bf529-6396c1acc4-","url":"https:\/\/pay.moolah.io\/a4dc89fcc-8ad-3f4c1bf529-6396c1acc4-","coin":"dogecoin","amount":"121526.39285714","address":"DS6frMZR5jFVEf9V6pBi9qtcVJa2JX5ewR","timestamp":1407579569}' }
        before do
          allow(client).to receive(:connection).and_return(test_connection)
          request_stubs.post(post_path) { |env| [ 200, {}, json_response ] }
        end

        context "allows transaction params to be given as argument" do
          let(:transaction) { client.create_transaction transaction_params }

          it_behaves_like :success_transaction
        end

        context "allows transaction params to be given in the block" do
          let(:transaction) do 
            client.create_transaction do |t|
              t.coin = "dogecoin"
              t.currency = "USD"
              t.amount = "20"
              t.product = "Coingecko Pro"
            end
          end

          it_behaves_like :success_transaction
        end
      end

      context "with optional parameters" do
        before do
          allow(client).to receive(:connection).and_return(test_connection)
          request_stubs.post(post_path) { |env| [ 200, {}, json_response ] }
        end
        let(:client) { Moolah::Client.new({ api_secret: "secret", ipn: "www.example.com/processed_payment" }) }
        let(:post_path) { "#{action_path}?amount=20&apiKey=1234567890&apiSecret=secret&coin=dogecoin&currency=USD&ipn=www.example.com%2Fprocessed_payment&product=Coingecko+Pro" }
        let(:json_response) { '{"status":"success","guid":"a4dc89fcc-8ad-3f4c1bf529-6396c1acc4-","url":"https:\/\/pay.moolah.io\/a4dc89fcc-8ad-3f4c1bf529-6396c1acc4-","coin":"dogecoin","amount":"121526.39285714","address":"DS6frMZR5jFVEf9V6pBi9qtcVJa2JX5ewR","timestamp":1407579569}' }
        let(:transaction) { client.create_transaction transaction_params }

        it_behaves_like :success_transaction
      end
    end

    context "failure transaction" do
      let(:client) { Moolah::Client.new }
      let(:post_path) { "#{action_path}?amount=20&apiKey=1234567890&coin=dogecoin&currency=USD&product=Coingecko+Pro" }
      let(:json_response) { '{"status":"failure"}' }
      let(:transaction) { client.create_transaction transaction_params }
      before do
        allow(client).to receive(:connection).and_return(test_connection)
        request_stubs.post(post_path) { |env| [ 200, {}, json_response ] }
      end

      it_behaves_like :failure_transaction
    end
  end

end

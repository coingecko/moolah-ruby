require 'moolah'

describe Moolah::Client do
  let(:request_stubs) { Faraday::Adapter::Test::Stubs.new }
  let (:test_connection) do
    Faraday.new do |builder|
      builder.adapter :test, request_stubs
    end
  end
  let(:client) { Moolah::Client.new }

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
    end
  end

  describe "#create_transaction" do
    let(:action_path) { "/private/merchant/create" }
    let(:transaction_params) { { coin: "dogecoin", amount: "20", currency: "USD", product: "Coingecko Pro" } }

    # Provide API Key first
    before do
      allow(Moolah).to receive(:api_key).and_return("1234567890")
      allow(Moolah).to receive(:api_secret).and_return("secret")
      allow(Moolah).to receive(:ipn).and_return("www.example.com/processed_payment")
    end

    shared_examples :success_transaction do
      it { expect(result[:status]).to eq("success") }
      it { expect(result[:guid]).to eq("a4dc89fcc-8ad-3f4c1bf529-6396c1acc4-") }
      it { expect(result[:address]).to eq("DS6frMZR5jFVEf9V6pBi9qtcVJa2JX5ewR") }
      it { expect(result[:url]).to eq("https://pay.moolah.io/a4dc89fcc-8ad-3f4c1bf529-6396c1acc4-") }
      it { expect(result[:coin]).to eq("dogecoin") }
      it { expect(result[:amount]).to eq("121526.39285714") }
      it { expect(result[:timestamp]).to eq(1407579569) }
    end

    shared_examples :failure_transaction do
      it { expect(result[:status]).to eq("failure") }
      it { expect(result[:guid]).to eq(nil) }
      it { expect(result[:address]).to eq(nil) }
      it { expect(result[:url]).to eq(nil) }
      it { expect(result[:coin]).to eq(nil) }
      it { expect(result[:amount]).to eq(nil) }
      it { expect(result[:timestamp]).to eq(nil) }
    end

    context "incomplete transaction parameters" do
      let(:client) { Moolah::Client.new }
      let(:incomplete_transaction_params) { { coin: "dogecoin", amount: "20", currency: "USD" } }

      it "throws ArgumentError" do
        expect { client.create_transaction(incomplete_transaction_params) }.to raise_error(ArgumentError)
      end
    end

    context "successful transaction" do
      context "without optional ipn_extra parameter" do
        before do
          allow(client).to receive(:connection).and_return(test_connection)
          request_stubs.post(post_path) { |env| [ 200, {}, json_response ] }
        end
        let(:post_path) { "#{action_path}?amount=20&apiKey=1234567890&coin=dogecoin&currency=USD&product=Coingecko+Pro" }
        let(:json_response) { '{"status":"success","guid":"a4dc89fcc-8ad-3f4c1bf529-6396c1acc4-","url":"https:\/\/pay.moolah.io\/a4dc89fcc-8ad-3f4c1bf529-6396c1acc4-","coin":"dogecoin","amount":"121526.39285714","address":"DS6frMZR5jFVEf9V6pBi9qtcVJa2JX5ewR","timestamp":1407579569}' }

        context "allows transaction params to be given as argument" do
          let(:result) { client.create_transaction transaction_params }

          it_behaves_like :success_transaction
        end
      end

      context "with optional ipn_extra parameter" do
        before do
          allow(client).to receive(:connection).and_return(test_connection)
          request_stubs.post(post_path) { |env| [ 200, {}, json_response ] }
        end
        let(:post_path) { "#{action_path}?amount=20&apiKey=1234567890&apiSecret=secret&coin=dogecoin&currency=USD&ipn=www.example.com%2Fprocessed_payment&product=Coingecko+Pro" }
        let(:json_response) { '{"status":"success","guid":"a4dc89fcc-8ad-3f4c1bf529-6396c1acc4-","url":"https:\/\/pay.moolah.io\/a4dc89fcc-8ad-3f4c1bf529-6396c1acc4-","coin":"dogecoin","amount":"121526.39285714","address":"DS6frMZR5jFVEf9V6pBi9qtcVJa2JX5ewR","timestamp":1407579569}' }

        let(:result) { client.create_transaction transaction_params }

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

  describe "#query_transaction" do
    let(:action_path) { "/private/merchant/status" }
    let(:post_path) { "#{action_path}?apiKey=1234567890&guid=1234-1234-1234" }
    before do
      allow(Moolah).to receive(:api_key).and_return("1234567890")
    end

    context "transaction does not exist" do
      before do
        allow(client).to receive(:connection).and_return(test_connection)
        request_stubs.post(post_path) { |env| [ 200, {}, json_response ] }
      end
      let(:json_response) { '{ "status": "failure", "reason": "No such transaction." }' }

      it "returns a symbolized has of the json response" do
        result = client.query_transaction({api_key: "1234567890", guid:"1234-1234-1234"})
        expect(result[:status]).to eq("failure")
        expect(result[:reason]).to eq("No such transaction.")
      end
    end

    context "transaction exists" do
      before do
        allow(client).to receive(:connection).and_return(test_connection)
        request_stubs.post(post_path) { |env| [ 200, {}, json_response ] }
      end
      let(:json_response) { '{
        "status": "success",
        "transaction": {
          "tx": {
              "amount": "26651.62068965",
              "coin": "dogecoin",
              "guid": "692-6c-e5fa17a37-4baa72bf7c5-78d88d6",
              "status": "cancelled",
              "tx": "-1"
          }
        }
      }' }

      it "returns a symbolized has of the json response" do
        result = client.query_transaction({api_key: "1234567890", guid:"1234-1234-1234"})
        expect(result[:status]).to eq("success")
        expect(result[:transaction][:tx][:amount]).to eq("26651.62068965")
        expect(result[:transaction][:tx][:coin]).to eq("dogecoin")
        expect(result[:transaction][:tx][:guid]).to eq("692-6c-e5fa17a37-4baa72bf7c5-78d88d6")
        expect(result[:transaction][:tx][:status]).to eq("cancelled")
        expect(result[:transaction][:tx][:tx]).to eq("-1")
      end
    end
  end

end

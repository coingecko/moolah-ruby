require 'moolah'

describe Moolah::Transaction do
  let (:complete_symbol_params) { { coin: "dogecoin", amount: "1234", currency: "USD", product: "Coingecko Pro" } }
  let (:complete_string_params) { { "coin" => "dogecoin", "amount" => "1234", "currency" => "USD", "product" => "Coingecko Pro" } }

  describe ".initialize" do
    it "accepts hash params of symbol keys" do
      transaction = Moolah::Transaction.new(complete_symbol_params)
      expect(transaction.coin).to eq("dogecoin")
    end

    it "accepts hash params of string keys" do
      transaction = Moolah::Transaction.new(complete_string_params)
      expect(transaction.coin).to eq("dogecoin")
    end

    it "throws ArgumentError if params is not a hash" do
      looks_like_a_hash_but_is_not = [ coin: "dogecoin", amount: "1234", currency: "USD", product: "Coingecko Pro" ]
      expect { Moolah::Transaction.new(looks_like_a_hash_but_is_not) }.to raise_error(ArgumentError)
    end

    it "allows block configuration" do
      transaction = Moolah::Transaction.new do |t|
        t.coin = "bitcoin"
        t.amount = "100"
        t.currency = "USD"
        t.product = "Coingecko Pro"
      end
      expect(transaction.coin).to eq("bitcoin")
      expect(transaction.amount).to eq("100")
      expect(transaction.currency).to eq("USD")
      expect(transaction.product).to eq("Coingecko Pro")
    end

    it "allows mix of param and block configuration" do
      transaction = Moolah::Transaction.new({ coin: "bitcoin", amount: "100" }) do |t|
        t.currency = "USD"
        t.product = "Coingecko Pro"
      end
      expect(transaction.coin).to eq("bitcoin")
      expect(transaction.amount).to eq("100")
      expect(transaction.currency).to eq("USD")
      expect(transaction.product).to eq("Coingecko Pro")
    end

    it "prioritizes values set in the block" do
      transaction = Moolah::Transaction.new(complete_symbol_params) do |t|
        t.currency = "MYR"
      end
      expect(transaction.currency).to eq("MYR")
    end
  end
end

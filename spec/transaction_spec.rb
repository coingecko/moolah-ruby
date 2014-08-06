require 'moolah'

describe Moolah::Transaction do
  let (:complete_params) { { coin: "dogecoin", amount: "1234", currency: "USD", product: "Coingecko Pro" } }

  describe ".initialize" do
    it "accepts hash params of required keys" do
      expect(Moolah::Transaction.new(complete_params)).to be_a(Moolah::Transaction)
    end

    it "throws ArgumentError if params is not a hash" do
      looks_like_a_hash_but_is_not = [ coin: "dogecoin", amount: "1234", currency: "USD", product: "Coingecko Pro" ]
      expect { Moolah::Transaction.new(looks_like_a_hash_but_is_not) }.to raise_error(ArgumentError)
    end
  end

end

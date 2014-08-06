require 'moolah'

describe Moolah::Transaction do
  let (:complete_params) { { coin: "dogecoin", amount: "1234", currency: "USD", product: "Coingecko Pro" } }

  describe ".initialize" do
    it "accepts params of required keys" do
      expect(Moolah::Transaction.new(complete_params)).to be_a(Moolah::Transaction)
    end
  end

end

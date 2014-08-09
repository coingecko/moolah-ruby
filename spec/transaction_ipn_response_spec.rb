require 'moolah'

describe Moolah::TransactionIPNResponse do
  context "correct payload" do

    shared_examples :successful_payload_parsing do
      it { expect(ipn_response.api_secret).to eq("secret") } 
      it { expect(ipn_response.guid).to eq("1234-1234-1234") } 
      it { expect(ipn_response.timestamp).to eq("123456789") } 
      it { expect(ipn_response.status).to eq("complete") } 
      it { expect(ipn_response.tx).to eq("abcdefghijkl") } 
      it { expect(ipn_response.ipn_extra).to eq("extrastuff") } 
    end

    context "string payload" do
      let(:payload_string) { "apiSecret=secret&guid=1234-1234-1234&timestamp=123456789&status=complete&tx=abcdefghijkl&ipn_extra=extrastuff" }
      let(:ipn_response) { Moolah::TransactionIPNResponse.new(payload_string) }

      it_behaves_like :successful_payload_parsing
    end

    context "symbol key hash payload" do
      let(:payload_symbol_hash) { {apiSecret: "secret", guid: "1234-1234-1234", timestamp: "123456789", status: "complete", tx: "abcdefghijkl", ipn_extra: "extrastuff" } }
      let(:ipn_response) { Moolah::TransactionIPNResponse.new(payload_symbol_hash) }

      it_behaves_like :successful_payload_parsing
    end

    context "string key hash payload" do
      let(:payload_string_hash) { { "apiSecret" => "secret", "guid" => "1234-1234-1234", "timestamp" => "123456789", "status" => "complete", "tx" => "abcdefghijkl", "ipn_extra" => "extrastuff" } }
      let(:ipn_response) { Moolah::TransactionIPNResponse.new(payload_string_hash) }

      it_behaves_like :successful_payload_parsing
    end
  end
end
require 'moolah/version'
require 'faraday'
require 'json'

module Moolah
  class Client
    CREATE_TRANSACTION_ACTION = "/private/merchant/create"
    QUERY_TRANSACTION_ACTION = "/private/merchant/status"

    # Initializes a new Client
    #
    # @param options [Hash]
    def initialize
      # Check for api key
      raise ArgumentError, "API Key is not set!" unless Moolah.api_key
    end

    def create_transaction(transaction_params = {})
      faraday_response = connection.post do |req|
        req.url CREATE_TRANSACTION_ACTION

        # Required fields
        req.params['apiKey'] = Moolah.api_key # apiKey (camel case) is the actual field
        req.params['coin'] = transaction_params[:coin] || transaction_params["coin"]
        req.params['currency'] = transaction_params[:currency] || transaction_params["currency"]
        req.params['amount'] = transaction_params[:amount] || transaction_params["amount"]
        req.params['product'] = transaction_params[:product] || transaction_params["product"]

        # Optional fields
        ipn_extra = transaction_params[:ipn_extra] || transaction_params["ipn_extra"]]
        if ipn_extra
          raise ArgumentError, "IPN is not set!" unless Moolah.ipn
          raise ArgumentError, "API Secret is not set!" unless Moolah.api_secret

          req.params['ipn_extra'] = ipn_extra
          req.params['apiSecret'] = Moolah.api_secret # apiSecret (camel case) is the actual field
          req.params['ipn'] = Moolah.ipn
        end
      end

      json_response = JSON.parse(faraday_response.body)
      symbolize_keys(json_response)
    end

    def query_transaction(params = {})
      guid = params[:guid] || params["guid"]

      faraday_response = connection.post do |req|
        req.url QUERY_TRANSACTION_ACTION

        req.params['apiKey'] = Moolah.api_key;
        req.params['guid'] = guid;
      end

      json_response = JSON.parse(faraday_response.body)
      symbolize_keys(json_response)
    end

    # Connection method for ease of stubbing
    def connection
      @connection ||= Faraday.new(url: Moolah.endpoint)
    end

    def symbolize_keys(hash)
      return hash unless hash.is_a?(Hash) 

      symbolized_hash = hash.inject({}) do |memo, (k,v)|
        memo[k.to_sym] = symbolize_keys(v)
        memo
      end
      symbolized_hash
    end
  end
end

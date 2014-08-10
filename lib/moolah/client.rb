require 'moolah/version'
require 'faraday'
require 'json'

module Moolah
  class Client
    CREATE_TRANSACTION_ACTION = "/v2/private/merchant/create"
    QUERY_TRANSACTION_ACTION = "/v2/private/merchant/status"

    def initialize
      # Check for API key
      raise ArgumentError, "API Key is not set!" unless Moolah.api_key
    end

    def create_transaction(transaction_params = {})
      coin = transaction_params[:coin] || transaction_params["coin"]
      currency = transaction_params[:currency] || transaction_params["currency"]
      amount = transaction_params[:amount] || transaction_params["amount"]
      product = transaction_params[:product] || transaction_params["product"]

      # Check all parameters present
      raise ArgumentError, "Missing transaction parameter(s)" unless coin && currency && amount && product

      request_body = { coin: coin, currency: currency, amount: amount, product: product, apiKey: Moolah.api_key }

      ipn = transaction_params[:ipn] || transaction_params["ipn"]
      if ipn
        ipn_extra = transaction_params[:ipn_extra] || transaction_params["ipn_extra"]
        request_body[:ipn] = ipn 
        request_body[:ipn_extra] = ipn_extra
        request_body[:apiSecret] = Moolah.api_secret
      end

      faraday_response = connection.post do |request|
        request.url CREATE_TRANSACTION_ACTION
        request.body = request_body
      end

      json_response = JSON.parse(faraday_response.body)
      symbolize_keys(json_response)
    end

    def query_transaction(params = {})
      guid = params[:guid] || params["guid"]

      request_body = { guid: guid, apiKey: Moolah.api_key }

      faraday_response = connection.post do |request|
        request.url QUERY_TRANSACTION_ACTION
        request.body = request_body
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

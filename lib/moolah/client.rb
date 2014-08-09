require 'moolah/version'
require 'moolah/transaction'
require 'faraday'
require 'json'

module Moolah
  class Client
    OPTIONAL_KEYS = [ :api_secret, :ipn ]

    CREATE_TRANSACTION_ACTION = "/private/merchant/create"
    QUERY_TRANSACTION_ACTION = "/private/merchant/status"

    attr_accessor *OPTIONAL_KEYS

    # Initializes a new Client
    #
    # @param options [Hash]
    def initialize(options = {})
      # Check for api key
      raise ArgumentError, "API Key is not set!" unless Moolah.api_key

      OPTIONAL_KEYS.each do |key|
        self.send("#{key}=", options[key]) if options[key]
        self.send("#{key}=", options[key.to_s]) if options[key.to_s]
      end
    end

    def create_transaction(transaction_params = {}, ipn_extra = nil)
      # Create transaction with validation off
      transaction = Transaction.new(transaction_params, false)

      # Allow transaction to be configured in block
      yield transaction if block_given? 

      # Validate!
      transaction.validate_keys

      faraday_response = connection.post do |req|
        req.url CREATE_TRANSACTION_ACTION

        # Required fields
        req.params['apiKey'] = Moolah.api_key
        req.params['coin'] = transaction.coin
        req.params['currency'] = transaction.currency
        req.params['amount'] = transaction.amount
        req.params['product'] = transaction.product

        # Optional fields
        req.params['apiSecret'] = api_secret if api_secret
        req.params['ipn'] = ipn if ipn
        req.params['ipn_extra'] = ipn_extra if ipn_extra
      end

      transaction.raw_response = faraday_response.body
      transaction.response = Moolah::TransactionResponse.new(transaction.raw_response)
      transaction
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

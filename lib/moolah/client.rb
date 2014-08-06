require 'moolah/version'
require 'moolah/transaction'

module Moolah
  class Client
    OPTIONAL_KEYS = [ :api_secret, :ipn ]

    attr_accessor *OPTIONAL_KEYS

    # Initializes a new Client
    #
    # @param options [Hash]
    def initialize(options = {})
      @connection = Faraday.new(url: Moolah.endpoint)

      OPTIONAL_KEYS.each do |key|
        if value_for_symbol = params[key] or value_for_string = params[key.to_s]
          self.send("#{key}=", value_for_symbol) if value_for_symbol
          self.send("#{key}=", value_for_string) if value_for_string
        end
      end
    end

    def create_transaction(transaction_params, ipn_extra = nil, &block)
      if block_given?
        transaction = Transaction.new(transaction_params, block)
      else
        transaction = Transaction.new(transaction_params)
      end

      @connection.post do |req|
        req.url "/private/merchant/create"

        # Required fields
        req.params['apiKey'] = Moolah.api_key
        req.params['coin'] = transaction.coin
        req.params['currency'] = transaction.currency
        req.params['amount'] = transaction.amount
        req.params['product'] = transaction.product

        # Optional fields
        (req.params['apiSecret'] = api_secret) if api_secret
        (req.params['ipn'] = ipn) if ipn
        (req.params['ipn_extra'] = ipn_extra) if ipn_extra
      end
    end

  end
end

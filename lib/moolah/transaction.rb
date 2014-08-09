require 'moolah/version'
require 'JSON'

module Moolah
  class Transaction
    TRANSACTION_KEYS = [ :coin, :currency, :amount, :product ].freeze

    attr_accessor *TRANSACTION_KEYS

    # Returns a TransactionResponse
    attr_accessor :response

    # Initializes a new Transaction
    #
    # @param params [Hash]
    # @raise [ArgumentError] Error raised when supplied argument is missing any of the required key/values
    def initialize(params = {}, validate = true)
      raise ArgumentError, "params must be a hash!" if !params.is_a?(Hash)

      # Assign values from params
      TRANSACTION_KEYS.each do |key|
        self.send("#{key}=", params[key]) if params[key]
        self.send("#{key}=", params[key.to_s]) if params[key.to_s]
      end

      # Allow assigning to be done within block
      yield self if block_given?

      validate_keys if validate
    end

    def validate_keys
      TRANSACTION_KEYS.each do |key|
        value = self.send("#{key}")
        if !value or value.empty?
          raise ArgumentError, "Missing transaction parameter: #{key}"
        end
      end
    end
  end

  class TransactionResponse
    RESPONSE_JSON_KEYS = [ :status, :guid, :address, :url, :coin, :amount, :timestamp ].freeze

    attr_accessor *RESPONSE_JSON_KEYS

    def initialize(json_response_string = "")
      raise ArgumentError, "JSON transaction response cannot be empty!" if json_response_string.empty?

      json_response_hash = JSON.parse(json_response_string)

      RESPONSE_JSON_KEYS.each do |key|
        self.send("#{key}=", json_response_hash[key.to_s])
      end
    end
  end

  class TransactionIPNResponse
    IPN_RESPONSE_PAYLOAD_KEYS = [ :api_secret, :guid, :timestamp, :status, :tx, :ipn_extra ].freeze

    KEY_TO_ACTUAL_FIELD_MAPPING = { :api_secret => :apiSecret }

    attr_accessor *IPN_RESPONSE_PAYLOAD_KEYS

    def initialize(payload = {})
      raise ArgumentError, "IPN response payload cannot be empty!" if payload.empty?

      if payload.is_a?(String) 
        parsed_payload = CGI.parse(payload) # {"a":["b"], "c":["d"]}
        payload_hash = Hash[parsed_payload.map {|key,values| [key.to_sym, values[0]]}] #{a: b, c: d}
      elsif payload.is_a?(Hash)
        payload_hash = payload
      else
        raise ArgumentError, "Wrong argument type!"
      end

      IPN_RESPONSE_PAYLOAD_KEYS.each do |key|
        actual_key = KEY_TO_ACTUAL_FIELD_MAPPING[key] ? KEY_TO_ACTUAL_FIELD_MAPPING[key] : key

        value = payload_hash[actual_key] || payload_hash[actual_key.to_s]
        self.send("#{key}=", value)
      end
    end
  end
end

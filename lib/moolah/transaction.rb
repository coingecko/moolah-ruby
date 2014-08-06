require 'moolah/version'

module Moolah
  class Transaction
    TRANSACTION_KEYS = [ :coin, :currency, :amount, :product ].freeze

    attr_accessor *TRANSACTION_KEYS

    # Initializes a new Transaction
    #
    # @param params [Hash]
    # @raise [ArgumentError] Error raised when supplied argument is missing any of the required key/values
    def initialize(params = {})
      raise ArgumentError, "params must be a hash!" if !params.is_a?(Hash)

      # Assign values from params
      TRANSACTION_KEYS.each do |key|
        self.send("#{key}=", params[key]) if params[key]
        self.send("#{key}=", params[key.to_s]) if params[key.to_s]
      end

      # Allow assigning to be done within block
      yield self if block_given?

      validate_keys
    end

    def validate_keys
      TRANSACTION_KEYS.each do |key|
        if !self.send("#{key}")
          raise ArgumentError, "Missing transaction parameter: #{key}"
        end
      end
    end
  end
end

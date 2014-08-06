require 'moolah/version'

module Moolah

  class Transaction
    TRANSACTION_KEYS = [ :coin, :currency, :amount, :product ].freeze

    attr_accessor *TRANSACTION_KEYS

    # Initializes a new Transaction
    #
    # @param params [Hash]
    # @raise [ArgumentError] Error raised when supplied argument is missing any of the required key/values
    def initialize(params)
      # Assign values from params
      TRANSACTION_KEYS.each do |key|
        if value_for_symbol = params[key] or value_for_string = params[key.to_s]
          if value_for_symbol
            self.send("#{key}=", value_for_symbol)
          end

          if value_for_string
            self.send("#{key}=", value_for_string)
          end
        end
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

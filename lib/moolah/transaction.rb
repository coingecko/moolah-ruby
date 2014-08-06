require 'moolah/version'

module Moolah

  class Transaction
    OPTIONS_KEYS = [ :coin, :currency, :amount, :product ].freeze

    attr_accessor *OPTIONS_KEYS

    def initialize(params)
      # Assign values from params
      OPTIONS_KEYS.each do |key|
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
      OPTIONS_KEYS.each do |key|
        if !self.send("#{key}")
          raise ArgumentError, "Missing transaction parameter: #{key}"
        end
      end
    end
  end

end

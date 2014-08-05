require 'moolah/version'

module Moolah
  module Configuration
    DEFAULT_ENDPOINT = "https://api.moolah.io/v2"
    DEFAULT_API_KEY = nil

    attr_accessor :api_key, :endpoint

    # When extended, call reset to set variable values to defaults
    def self.extended(mod)
      mod.reset
    end

    def reset
      self.api_key = DEFAULT_API_KEY
      self.endpoint = DEFAULT_ENDPOINT
    end

    def configure
      yield self
    end

  end
end

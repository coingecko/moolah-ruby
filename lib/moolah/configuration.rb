require 'moolah/version'

module Moolah
  module Configuration
    DEFAULT_ENDPOINT = "https://api.moolah.io/v2"
    DEFAULT_API_KEY = nil

    attr_accessors :api_key, :end_point

    def configure
      yield self
    end
  end
end

# Moolah::Ruby

Wrapper API for Moolah's Transaction API (v2)

## Installation

Add this line to your application's Gemfile:

```bash
gem 'moolah-ruby'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install moolah-ruby
```

## Usage

Configuration:
```ruby
require 'moolah'

Moolah.configure do |config|
  config.api_key = ENV['API_KEY']
  config.api_secret = ENV['API_SECRET'] # necessary for IPN response
  # config.endpoint = "https://api.moolah.io/v2"
end
```

Create a transaction:
```ruby
moolah_client = Moolah::Client.new

# No IPN Response
response = moolah_client.create_transaction(coin: "bitcoin", currency: "USD", amount: "20", product: "Coingecko Pro")

# IPN Response
response = moolah_client.create_transaction(coin: "bitcoin", currency: "USD", amount: "20", product: "Coingecko Pro", ipn: "www.example.com/processed_payment", ipn_extra: "{ user_id: 1 }")

response[:status] # "success"
response[:guid] # "1234-1234-1234-1234"
response[:address] # "abcdefghijklmnopqrstuvwxyz"
# etc.
```

Query a transaction:
```ruby
query_result = moolah_client.query_transaction(guid:"1234-1234-1234-1234")

query_result[:status] # "success"
query_result[:transaction][:tx][:coin] # "bitcoin"
# etc.
```

## Contributing

1. Fork it ( https://github.com/coingecko/moolah-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

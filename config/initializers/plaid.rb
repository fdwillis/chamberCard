require 'plaid'

configuration = Plaid::Configuration.new
configuration.server_index = Plaid::Configuration::Environment["sandbox"]
configuration.api_key["PLAID-CLIENT-ID"] = ENV['plaidClient']
configuration.api_key["PLAID-SECRET"] = ENV['plaidSecret']

api_client = Plaid::ApiClient.new(configuration)

@plaidClient = Plaid::PlaidApi.new(api_client)
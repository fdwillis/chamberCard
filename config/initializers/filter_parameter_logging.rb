# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:stripeCustomerID, :stripeMerchantID, :password, :carts, :connectAccount, :id, :phone, :uuid, :accessPin, :card, :cvc]

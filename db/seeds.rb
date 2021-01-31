User.destroy_all
manager = User.create!(timeKitID: "7e2c060a-bcfa-4e29-a8e0-8fe7e0e1a4db",username: 'manager',stripeCustomerID: 'cus_Iqv08b4X8oAFzW', stripeMerchantID: 'acct_1IFBXBQYnr9HT5Wc', email: 'm@m.com', password: 'mmmmmmmm', uuid: SecureRandom.uuid[0..7], accessPin: 'manager')

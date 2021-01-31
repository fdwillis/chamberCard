User.destroy_all
manager = User.create!(username: 'manager',stripeCustomerID: 'cus_Iqv08b4X8oAFzW', stripeMerchantID: 'acct_1IFBXBQYnr9HT5Wc', email: 'm@m.com', password: 'mmmmmmmm', uuid: SecureRandom.uuid[0..7], accessPin: 'manager')

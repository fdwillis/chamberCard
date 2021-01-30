User.destroy_all
manager = User.create!(username: 'manager', stripeMerchantID: 'acct_1IFBXBQYnr9HT5Wc', email: 'm@m.com', password: 'mmmmmmmm', uuid: SecureRandom.uuid[0..7], accessPin: 'manager')

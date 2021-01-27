User.destroy_all
manager = User.create!(username: 'manager2', stripeMerchantID: 'acct_1IDJ8iQmUV7SXPrI', email: 'm@m.com', password: 'mmmmmmmm', uuid: SecureRandom.uuid[0..7], accessPin: 'manager')

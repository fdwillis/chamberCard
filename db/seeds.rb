User.destroy_all
manager = User.create!(username: 'manager2', stripeSourceVerified: true, stripeUserID: 'acct_1I9ZIUQhh3tbHkEK', email: 'm2@m.com', password: 'mmmmmmmm', uuid: SecureRandom.uuid[0..7], accessPin: 'manager')

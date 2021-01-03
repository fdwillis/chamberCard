User.destroy_all
manager = User.create!(username: 'manager', stripeSourceVerified: true, stripeUserID: 'acct_1I49yyQnuCIsERus', email: 'm@m.com', password: 'mmmmmmmm', uuid: SecureRandom.uuid[0..7], accessPin: 'manager')

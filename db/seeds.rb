User.destroy_all
User.create!(email: 'v@v.com', password: 'vvvvvvvv', username: 'v', uuid: SecureRandom.uuid[0..7])
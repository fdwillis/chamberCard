Product.destroy_all
Image.destroy_all
User.destroy_all
manager = User.create!(timeKitID: "7e2c060a-bcfa-4e29-a8e0-8fe7e0e1a4db",username: 'manager',stripeCustomerID: 'cus_Iqv08b4X8oAFzW', stripeMerchantID: 'acct_1IFBXBQYnr9HT5Wc', email: 'm@m.com', password: 'mmmmmmmm', uuid: SecureRandom.uuid[0..7], accessPin: 'manager')
customer = User.create(stripeCustomerID: "cus_J8Nd2h2TimRRA0", stripeMerchantID: nil, timeKitID: nil, phone: "4143742806", accessPin: "customer", street: "487 n 66", city: "mil", state: "wi", country: "USA", latitude: nil, longitude: nil, twilioPhoneVerify: false, referredBy: nil, username: "R", email: "fdwillis7@gmail.com", password: 'ffffffff')
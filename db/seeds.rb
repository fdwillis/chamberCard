Product.destroy_all
Image.destroy_all
User.destroy_all
manager = User.create!(timeKitID: "7e2c060a-bcfa-4e29-a8e0-8fe7e0e1a4db",username: 'manager',stripeCustomerID: 'cus_JBeja3MqqIeuBl', stripeMerchantID: 'acct_1IZHNUQVqSB7BoLG', email: 'm@m.com', password: 'mmmmmmmm', uuid: SecureRandom.uuid[0..7], accessPin: 'manager')

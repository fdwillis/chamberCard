FactoryBot.define do
  factory :user do |u|
    sequence(:email) {|s| "rspec#{SecureRandom.uuid[0..5]}@example.com"}
    password {'12345678'}
    sequence(:username) {|s| "user-#{SecureRandom.uuid[0..5]}"}
    password_confirmation {"12345678"}
    uuid {SecureRandom.uuid[0..5]}
 
	   
	  factory :virtual do
			accessPin {'virtual'}
	    uuid {SecureRandom.uuid[0..5]}
		end
		factory :manager do
			accessPin {'manager'}
	    stripeMerchantID {}
	    uuid {SecureRandom.uuid[0..5]}
		end
		factory :managerStripe do
			accessPin {'manager'}
			email {"m@m.com"}
			password {"mmmmmmmm"}
			password_confirmation {"mmmmmmmm"}
			stripeCustomerID {"cus_JBeja3MqqIeuBl"}
	    stripeMerchantID {'acct_1Ijuj1QXl4puf0Hk'}
	    uuid {SecureRandom.uuid[0..5]}
		end
		factory :managerStripeVerified do
			accessPin {'manager'}
			stripeCustomerID {"cus_JkwOeP1qx8trER"}
	    stripeMerchantID {"acct_1Ijuj1QXl4puf0Hk"}
	    uuid {SecureRandom.uuid[0..5]}
		end
		factory :managerStripeVerified2 do
			accessPin {'manager'}
			stripeCustomerID {"cus_JkwOeP1qx8trER"}
	    stripeMerchantID {"acct_1Ijuj1QXl4puf0Hk"}
	    uuid {SecureRandom.uuid[0..5]}
		end
		factory :trustee do
			accessPin {'trustee'}
	    uuid {SecureRandom.uuid[0..5]}
		end
		factory :customer do
			accessPin {'customer'}
	    stripeCustomerID {}
	    uuid {SecureRandom.uuid[0..5]}
		end
		factory :customerStripe do
			accessPin {'customer'}
			email {'tcl@tcl.com'}
			password {'tcltcltcl'}
			password_confirmation {'tcltcltcl'}
	    stripeCustomerID {"cus_JOdKTJ6EkpXcHT"}
	    uuid {SecureRandom.uuid[0..5]}
		end
		factory :customerStripeVerified do
			accessPin {'customer'}
	    stripeCustomerID {"cus_ItInDaoIV4SHu8"}
	    uuid {SecureRandom.uuid[0..5]}
		end
		factory :customerStripeVerified2 do
			accessPin {'customer'}
	    stripeCustomerID {"cus_Jfqd1KjUsg9yvR"}
	    uuid {SecureRandom.uuid[0..5]}
		end
		factory :admin do
			accessPin {'admin'}
	    uuid {SecureRandom.uuid[0..5]}
		end
  end
# stripeUserID {}
# 	    stripeSubscription {Stripe::Subscription.list().map(&:id)[rand(0..Stripe::Subscription.list().map(&:id).count)]}
#plan_HDINkxIk831po5
end



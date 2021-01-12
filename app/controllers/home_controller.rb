class HomeController < ApplicationController
	before_action :authenticate_user!

	def profile
		if current_user
			if current_user&.stripeUserID
				callCurl = current_user.showStripeUserAPI

				if callCurl['success']
					@sources = !callCurl['source'].blank? ? callCurl['source'] : callCurl['sources']
					
					if !current_user.manager?
						@phone = callCurl['stripeCustomer']['phone']
						@name = callCurl['stripeCustomer']['name']
						@email = callCurl['stripeCustomer']['email']

					else
						
						if callCurl['stripeCustomer']['capabilities']["card_payments"] == "inactive" &&
							 callCurl['stripeCustomer']['capabilities']["transfers"] == "inactive"
							@pending = true
						end

						if !callCurl['stripeCustomer']['individual'].blank?
							@phone = callCurl['stripeCustomer']['individual']['phone'][2..12]
							@email = callCurl['stripeCustomer']['individual']['email']
						end
					end
				end
			end
		else
			reset_session
		end
	end

	def membership
		profile
		# if current member show membership with discount saving
		# when creating plans add lookup_keys to be able to divide by monthly/annual

		if current_user&.authentication_token
			# low store
			basicMonthly = ab_test(:basicMonthlyMembership, '1I8T1pHvKdEDURjL2CmrNeGT', {'1I8T1qHvKdEDURjLyI58Lxb4'=> 5}, {'1I8T1qHvKdEDURjLgJjXRvgZ'=> 4})
			saverMonthly = ab_test(:saverMonthlyMembership, '1I8T4CHvKdEDURjLD0FNULvK' , {'1I8T4CHvKdEDURjLXWM6XXEc' => 5}, {'1I8T4CHvKdEDURjLyg4f2LXK' => 4})
			eliteMonthly = ab_test(:eliteMonthlyMembership, '1I8T4xHvKdEDURjLtEaXVM8M' , {'1I8T4xHvKdEDURjLp9Os3fqI' => 5}, {'1I8T4xHvKdEDURjLdJNuoxOR' => 4})
		

			@basicMonthlyMembership = Stripe::Price.retrieve("price_#{basicMonthly}")
			@saverMonthlyMembership = Stripe::Price.retrieve("price_#{saverMonthly}")
			@eliteMonthlyMembership = Stripe::Price.retrieve("price_#{eliteMonthly}")

		end
		
	end
end
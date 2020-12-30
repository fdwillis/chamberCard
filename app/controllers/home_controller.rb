class HomeController < ApplicationController

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
end
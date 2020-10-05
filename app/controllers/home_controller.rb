class HomeController < ApplicationController

	def profile
		if current_user&.stripeUserID
			callCurl = current_user.showStripeUserAPI

			if callCurl['success']
				@sources = callCurl['sources']

				if !current_user.manager?
					@phone = callCurl['stripeCustomer']['phone']
					@name = callCurl['stripeCustomer']['name']
					@email = callCurl['stripeCustomer']['email']

				else
					
					if callCurl['stripeCustomer']['capabilities']["card_payments"] == "inactive" &&
						 callCurl['stripeCustomer']['capabilities']["transfers"] == "inactive"
						@pending = true
					end

					if callCurl['stripeCustomer']['individual']['phone']
						@phone = callCurl['stripeCustomer']['individual']['phone'][2..12]
						@email = callCurl['stripeCustomer']['individual']['email']
					end
				end
			else
				reset_session
				redirect_to services_path
			end
		end
	end

  def service_worker
  	
  end

  def manifest
  	
  end
end
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
			curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "" -X GET #{SITEurl}/v1/subscriptions?storeCost=#{ENV['storeCost']}`

	    response = Oj.load(curlCall)
	    
# debugger
	    if !response.blank? && response['success']
				# @annualPlans = find the annual plan to the monthly plan pulled from A/B test
				
				@basicMonthlyMembership = response['basicMonthly']
				@saverMonthlyMembership = response['saverMonthly']
				@eliteMonthlyMembership = response['eliteMonthly']
				
				

				# filter to show for ab pricing

			else
				flash[:alert] = "Trouble connecting. Try again later."
			end
		end
		
	end
end
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

			loadBasic = ENV["basicMonthlyMembership"].split(",")
			loadSaver = ENV["saverMonthlyMembership"].split(",")
			loadElite = ENV["eliteMonthlyMembership"].split(",")

			basicMonthly = ab_test(:basicMonthlyMembership, {loadBasic[0] => 2} , {loadBasic[1]=> 6}, {loadBasic[2]=> 2})
			saverMonthly = ab_test(:saverMonthlyMembership, {loadSaver[0] => 2} , {loadSaver[1] => 6}, {loadSaver[2] => 2})
			eliteMonthly = ab_test(:eliteMonthlyMembership, {loadElite[0] => 2} , {loadElite[1] => 6}, {loadElite[2] => 2})
		
			@basicMonthlyMembership = Stripe::Price.retrieve("price_#{basicMonthly}")
			@saverMonthlyMembership = Stripe::Price.retrieve("price_#{saverMonthly}")
			@eliteMonthlyMembership = Stripe::Price.retrieve("price_#{eliteMonthly}")

			if current_user.member?
				@subsc = Stripe::Subscription.list({customer: current_user.stripeUserID})['data'][0]
				@prod = Stripe::Product.retrieve(@subsc ['items']['data'][0]['price']['product'])
				@price = Stripe::Price.retrieve(@subsc ['items']['data'][0]['price']['id'])
			end

		end
		
	end

	def join

		if current_user.missingSub?

			params = {price: joinParams[:plan]}.to_json
			
			curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d '#{params}' -X POST #{SITEurl}/v1/subscriptions`
			
			response = Oj.load(curlCall)

			if !response.blank? && response['success'] && current_user.update_attributes(stripeSubscription:  response['stripeSubscription'], serviceFee: response['serviceFee'])
				flash[:success] = "You are now a member!"
	      redirect_to membership_path
	    else
				flash[:error] = response['error']
	      redirect_to membership_path
	    end
	  else
			flash[:error] = "Payment required to become a member"
      redirect_to profile_path
    end
	end

	private

	def joinParams
		paramsClean = params.require(:join).permit(:plan)
	end
end
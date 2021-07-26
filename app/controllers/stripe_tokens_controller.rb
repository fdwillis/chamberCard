class StripeTokensController < ApplicationController
before_action :authenticate_user!

	def create
		
		callCurl2 = current_user.updateStripeCustomerAPI(!stripeCardTokenParams.blank? ? stripeCardTokenParams : newStripeBankTokenParams )
		
		if callCurl2['success']

			if !stripeCardTokenParams.blank?
				callCurl = current_user.createStripeCardTokenAPI(stripeCardTokenParams)
			else
				callCurl = current_user.createStripeBankTokenAPI(newStripeBankTokenParams)
			end

			
			if callCurl['success']
				tokenReady = callCurl['token']
				
				source = current_user.attachSourceStripe(tokenReady)

				if source['success']
					flash[:success] = "Payment added"
					redirect_to profile_path
				else
					flash[:error] = source
					redirect_to profile_path
				end
			else
				
				flash[:error] = callCurl
				redirect_to profile_path
			end
		else
			
			flash[:error] = callCurl2
			redirect_to profile_path
		end
	end

	private

	def stripeCardTokenParams
		paramsClean = params.require(:newStripeCardToken).permit(:number, :exp_year, :exp_month, :cvc, :name, :phone)
		return paramsClean.reject{|_, v| v.blank?}
	end

	def newStripeBankTokenParams
		paramsClean = params.require(:newStripeBankToken).permit(:account_holder_name, :routing_number, :account_number)
		return paramsClean.reject{|_, v| v.blank?}
	end

end
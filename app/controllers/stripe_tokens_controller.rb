class StripeTokensController < ApplicationController
before_action :authenticate_user!

	def create
		callCurl2 = current_user.updateStripeCustomerAPI(params[:newStripeToken])
		
		if callCurl2['success']
			if !newStripeCardTokenParams.blank?
				callCurl = current_user.createStripeCardTokenAPI(params[:newStripeToken])
			end

			if !newStripeBankTokenParams.blank?
				callCurl = current_user.createStripeBankTokenAPI(params[:newStripeToken])
			end

			
			if callCurl['success']
				tokenReady = callCurl['token']
				
				source = current_user.attachSourceStripe(tokenReady)

				if source['success']
					flash[:success] = "Payment added"
					redirect_to request.referrer
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

	def newStripeCardTokenParams
		params.require(:newStripeToken).permit(:number, :exp_year, :exp_month, :cvc)
	end

	def newStripeBankTokenParams
		params.require(:newStripeToken).permit(:account_holder_name, :routing_number, :account_number)
	end

end
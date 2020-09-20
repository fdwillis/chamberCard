class StripeTokensController < ApplicationController
before_action :authenticate_user!

	def create
		callCurl = current_user.createStripeTokenAPI(params[:newStripeToken])
		
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
			redirect_to profile_path(newStripeToken)
		end
	end

	private

	def newStripeToken
		params.require(:newStripeToken).permit(:number, :exp_year, :exp_month, :cvc)
	end

end
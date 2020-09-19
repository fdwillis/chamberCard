class StripeTokensController < ApplicationController
before_action :authenticate_user!

	def create
		callCurl = current_user.createStripeTokenAPI(params[:newStripeToken])

		if callCurl['success']

			tokenReady = callCurl['token']

			source = current_user.attachSourceStripe(tokenReady)

			if source['success']
				flash[:success] = "Customer account created"
				redirect_to profile_path
			else
				flash[:error] = callCurl['message']
				redirect_to profile_path
			end
			
		else
			flash[:error] = callCurl['message']
			redirect_to profile_path
		end
	end
end
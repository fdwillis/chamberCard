class StripeCustomersController < ApplicationController
before_action :authenticate_user!

	def create
		callCurl = current_user.createStripeCustomerAPI

		if callCurl['success']
			flash[:success] = "Customer account created"
			redirect_to profile_path
		else
			flash[:error] = callCurl['message']
			redirect_to profile_path
		end
	end

	def update
		
	end

	private

	def stripeCustomerParams
		params.require(:stripeCustomerUpdate).permit(:username, :email, :phone)
	end
end
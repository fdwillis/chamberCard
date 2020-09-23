class StripeCustomersController < ApplicationController
before_action :authenticate_user!

	def create
		callCurl = current_user.createStripeCustomerAPI

		if callCurl['success']
			flash[:success] = "Customer account created"
			redirect_to request.referrer
		else
			flash[:error] = callCurl['message']
			redirect_to profile_path
		end
	end

	def update
		callCurl = current_user.updateStripeCustomerAPI(params[:updateCustomer])

		if callCurl['success']
			flash[:success] = "Stripe Account Updated"
			redirect_to request.referrer
		else
			flash[:error] = callCurl['error']
			redirect_to profile_path
		end

	end

	private

	def stripeCustomerParams
		params.require(:stripeCustomerUpdate).permit(:username, :email, :phone)
	end
end
class StripePayoutsController < ApplicationController
before_action :authenticate_user!

	def index
		callCurl = current_user&.indexStripePayoutsAPI(params)

		if callCurl['success']
			@payouts = callCurl['payoutsArray']
			
		else
			flash[:error] = callCurl['message']
			redirect_to profile_path
		end
	end

	def show
		callCurl = current_user.present? ? current_user&.showStripeCustomerAPI(params[:id]) : User.showStripeCustomerAPI(params[:id])
		if callCurl['success']
			@customer = callCurl['stripeCustomer']
			@sellerID = callCurl['stripeSeller']
			@payments = callCurl['payments']
		else
			flash[:error] = callCurl['message']
			redirect_to stripe_customers_path
		end
	end

	private

	def stripeCustomerParams
		paramsClean = params.require(:stripeCustomerUpdate).permit(:username, :email, :phone)
		return paramsClean.reject{|_, v| v.blank?}
	end
end
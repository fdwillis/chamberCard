class StripeSubscriptionsController < ApplicationController
before_action :authenticate_user!

	def index
		callCurl = current_user&.indexStripeCustomerAPI(params)

		if callCurl['success']
			@customers = callCurl['customers']['data']
			@hasMore = callCurl['customers']['has_more']
			@stripeMerchantID = callCurl['stripeMerchantID']
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

	def create
		callCurl = current_user&.createStripeSubscriptionAPI(stripeSubscriptionParams)

		if callCurl['success']
			flash[:success] = "Your Plan Was Created!"
			redirect_to charges_path
		else
			flash[:error] = callCurl['error']
			redirect_to new_charge_path
		end
	end

	def update
		callCurl = current_user&.updateStripeCustomerAPI(params[:updateCustomer])

		if callCurl['success']
			flash[:success] = "Account Updated"
			redirect_to request.referrer
		else
			flash[:error] = callCurl['error']
			redirect_to profile_path
		end

	end

	def new
		if params['id'].include?('price_')
		else
			flash[:error] = "Invalid Plan"
			redirect_to request.referrer
		end
	end

	private

	def stripeSubscriptionParams
		paramsClean = params.require(:newSubscription).permit(:stripePriceID, :quantity)
		return paramsClean.reject{|_, v| v.blank?}
	end
end
class StripeCustomersController < ApplicationController
before_action :authenticate_user!

	

	def index
		callCurl = current_user&.indexStripeCustomerAPI

		if callCurl['success']
			@customers = callCurl['customers']
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
		end
	end

	def create
		callCurl = current_user&.createStripeCustomerAPI

		if callCurl['success']
			flash[:success] = "Lets Get Started!"
			redirect_to request.referrer
		else
			flash[:error] = callCurl['message']
			redirect_to profile_path
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

	def resendCode
		callCurl = current_user&.resendTwilioPhoneAPI

		if callCurl['success']
			flash[:success] = "Verification Sent"
			redirect_to verify_phone_path
		else
			flash[:error] = callCurl['message']
			redirect_to verify_phone_path
		end
	end

	private

	def stripeCustomerParams
		paramsClean = params.require(:stripeCustomerUpdate).permit(:username, :email, :phone)
		return paramsClean.reject{|_, v| v.blank?}
	end
end
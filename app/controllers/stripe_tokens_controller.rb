	class StripeTokensController < ApplicationController
before_action :authenticate_user!

	def create
		if !stripeTokenParams.blank?
			if !stripeTokenParams[:routing_number].blank?
				callCurl = current_user.createStripeBankTokenAPI(stripeTokenParams)
			elsif !stripeTokenParams[:cvc].blank?
				callCurl = current_user.createStripeCardTokenAPI(stripeTokenParams)
			elsif !stripeTokenParams[:percentToInvest].blank?
				current_user.update(phone: stripeTokenParams[:phone], percentToInvest: stripeTokenParams[:percentToInvest].to_i)
				callCurl = current_user.updateUserAPI
			end
		end

		if callCurl['success']
			if callCurl['token'].present?
				tokenReady = callCurl['token']['id']
				
				sourceX = current_user.attachSourceStripe(tokenReady)

				if sourceX['success']
					flash[:success] = "Payment added"
					redirect_to profile_path
				else
					flash[:error] = sourceX
					redirect_to profile_path
				end
			else
				flash[:success] = "Percentage Updated"
				redirect_to profile_path
			end
		else
			
			flash[:error] = callCurl
			redirect_to profile_path
		end
		
	end

	private

	def stripeTokenParams
		paramsClean = params.require(:stripeToken).permit(:number, :exp_year, :exp_month, :cvc, :name, :phone, :account_holder_name, :account_holder_type, :routing_number, :account_number, :percentToInvest)
		return paramsClean.reject{|_, v| v.blank?}
	end
end
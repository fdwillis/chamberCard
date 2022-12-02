class StripePayoutsController < ApplicationController

	def index
		callCurl = !current_user&.stripeCustomerID.blank? ? User.indexStripePayoutsAPI(params,current_user) : User.indexStripePayoutsAPI(params,nil)

		if callCurl['success']
			@payouts = callCurl['payoutsArray']
			
		else
			flash[:error] = callCurl['message']
			redirect_to profile_path
		end
	end

	def new
	end

	def preview_payout
		@startDate = params[:startDate]
		@endDate = params[:endDate]

		validateTopUps = []
		investedAmountRunning = 0
		@validPaymentIntents = Stripe::PaymentIntent.list({limit: 100, created: {lt: @endDate.to_time.to_i, gt: @startDate.to_time.to_i}})['data'].reject{|e| e['charges']['data'][0]['refunded'] == true}.reject{|e| e['charges']['data'][0]['captured'] == false}

		@validPaymentIntents.each do |payint|
			if !payint['metadata'].blank? && payint['metadata']['percentToInvest'].to_i > 0 
				amountForDeposit = payint['amount'] - (payint['amount']*0.029).to_i + 30
				investedAmount = amountForDeposit * (payint['metadata']['percentToInvest'].to_i * 0.01)
				investedAmountRunning += investedAmount
			end
		end

		@amountInvested = investedAmountRunning
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
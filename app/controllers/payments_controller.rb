class PaymentsController < ApplicationController
	before_action :authenticate_user!

	def index
		#showing payments of id passed
		callCurl = current_user&.showStripeCustomerAPI(params[:stripe_customer_id])
		if callCurl['success']
			@payments = callCurl['payments']['data']
		end
	end
end
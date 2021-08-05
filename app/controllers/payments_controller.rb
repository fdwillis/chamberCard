class PaymentsController < ApplicationController
	before_action :authenticate_user!

	def index
		grabCart
		if current_user&.authentication_token

	  	if session[:payments]
				@payments = session[:payments] #edit stripe session meta for scheduling
			else
				curlCall = current_user&.indexStripeChargesAPI(params)
			  response = Oj.load(curlCall)
			  
				@payments = response['charges'] #edit stripe session meta for scheduling
				session[:payments] = @payments

			  if response['success']
					@hasMore = response['has_more']
		    end
			end
		else
			current_user = nil
      reset_session
		end
	end
end
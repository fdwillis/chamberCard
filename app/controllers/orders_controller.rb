class OrdersController < ApplicationController
	before_action :authenticate_user!
	
	def index
		if current_user&.authentication_token
			curlCall = current_user&.indexStripeOrdersAPI(params)
				
    	response = Oj.load(curlCall)
				debugger
	    if response['success']
				@actualCharges = response['actualOrders']
				@hasMore = response['has_more']
			elsif response['message'] == "No purchases found"
				@message = response['message']
			else
				flash[:error] = response['message']
			end

		else
			current_user = nil
      reset_session
		end
	end
end
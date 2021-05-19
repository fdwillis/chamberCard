class OrdersController < ApplicationController
	before_action :authenticate_user!
	
	def index
		if current_user&.authentication_token
			chargesNcustomers
			@actualCharges = session[:actualCharges] #edit stripe session meta for scheduling
		else
			current_user = nil
      reset_session
		end
	end
end
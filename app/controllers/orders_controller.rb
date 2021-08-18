class OrdersController < ApplicationController
	before_action :authenticate_user!
	
	def index
		if current_user&.authentication_token
			
			@orders = session[:fetchedPendingOrders]
			@hasMore = session[:pendingOrdersHasMore]
			
		else
			current_user = nil
      reset_session
		end
	end
end
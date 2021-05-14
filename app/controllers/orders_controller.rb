class OrdersController < ApplicationController
	before_action :authenticate_user!
	
	def index
		if current_user&.authentication_token
				chargesNcustomers

			if !session[:invoices].blank?
				@invoices = session[:invoices]
				@pending = session[:pending]
				@customerCharges = session[:customerCharges] #edit lineItems meta for scheduling
				
				if session[:charges].blank?
					anonCharges = []

					session[:charges].each do |anon|
						
						if anon['lineItems'].map{|litm| Stripe::Product.retrieve(litm['price']['product'], {stripe_account: ENV['connectAccount']})['type'] }.include?("service")
							anonCharges << anon
						end
					end
					session[:charges] = anonCharges
					@anonCharges = session[:charges] #edit stripe session meta for scheduling
				else
					@anonCharges = session[:charges] #edit stripe session meta for scheduling
				end
			end
		else
			current_user = nil
      reset_session
		end



















		
	end
end
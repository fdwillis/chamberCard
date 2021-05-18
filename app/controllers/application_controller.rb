class ApplicationController < ActionController::Base
	before_action :configure_permitted_parameters, if: :devise_controller?
	before_action :grabCart

	def chargesNcustomers
		if current_user&.owner?
			# user
			# what
			# sess or inv
			curlCall = Charge.APIindex(current_user)
			
	    response = Oj.load(curlCall)
	    
	    if response['success']
				session[:invoices] = response['invoices']
				session[:pending] = response['pending']
				session[:charges] = response['charges'] #edit stripe session meta for scheduling
				session[:customerCharges] = response['customerCharges']#edit lineItems meta for scheduling
			elsif response['message'] == "No purchases found"
				@message = response['message']
			else
				flash[:error] = response['message']
			end
		end

		if current_user&.customer?
			curlCall = Charge.APIindex(current_user)
			
	    response = Oj.load(curlCall)
	    
	    if response['success']
				session[:invoices] = response['invoices']
				session[:pending] = response['pending']
				session[:charges] = response['charges'] #edit stripe session meta for scheduling
				session[:customerCharges] = response['customerCharges']#edit lineItems meta for scheduling
			elsif response['message'] == "No purchases found"
				@message = response['message']
			else
				flash[:error] = response['message']
			end
		end
		
	end

	def grabCart
		if current_user&.authentication_token
			curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X GET #{SITEurl}/v1/carts`
			
	    response = Oj.load(curlCall)
	    
	    if response['success']
	    	@cart = response.merge(stripeCapturePercentage: ENV['stripeCapturePercentage'].to_f * 0.01, tenPercentDepositCoupon: ENV['tenPercentDepositCoupon'], thirtyPercentDepositCoupon: ENV['thirtyPercentDepositCoupon'], fiftyPercentDepositCoupon: ENV['fiftyPercentDepositCoupon'])
	    	session[:cart] = response.merge(stripeCapturePercentage: ENV['stripeCapturePercentage'].to_f * 0.01, tenPercentDepositCoupon: ENV['tenPercentDepositCoupon'], thirtyPercentDepositCoupon: ENV['thirtyPercentDepositCoupon'], fiftyPercentDepositCoupon: ENV['fiftyPercentDepositCoupon'])
	    end
	  else
	  	
	  	@cartID = session[:cart_id].present? ? session[:cart_id] : session[:cart_id] = rand(0..1000) + rand(0..1000000)

	  	curlCall = `curl -H "appName: #{ENV['appName']}" -X GET #{SITEurl}/v1/carts?cartID=#{@cartID}`
			
	    response = Oj.load(curlCall)
	    
	    if response['success']
	    	@cart = response.merge(stripeCapturePercentage: ENV['stripeCapturePercentage'].to_f * 0.01, tenPercentDepositCoupon: ENV['tenPercentDepositCoupon'], thirtyPercentDepositCoupon: ENV['thirtyPercentDepositCoupon'], fiftyPercentDepositCoupon: ENV['fiftyPercentDepositCoupon'])
	    	
	    	session[:cart] = response.merge(stripeCapturePercentage: ENV['stripeCapturePercentage'].to_f * 0.01, tenPercentDepositCoupon: ENV['tenPercentDepositCoupon'], thirtyPercentDepositCoupon: ENV['thirtyPercentDepositCoupon'], fiftyPercentDepositCoupon: ENV['fiftyPercentDepositCoupon'])
	    	
	    	@lineItems = []
	    	
	    	@cart['carts'].each do |cartInfo|
					cartInfo['cart'].each do |item|
						@lineItems << {price: item['stripePriceInfo']['id'], quantity: item['quantity']}
						@serviceFee = @cart['serviceFee']
					end
				end

				session[:lineItems] = @lineItems
	    end
	  end

	end

	protected
	def configure_permitted_parameters
	  devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :email, :password, :password_confirmation]) 
  end
end

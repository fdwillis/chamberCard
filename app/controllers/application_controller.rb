class ApplicationController < ActionController::Base
	before_action :configure_permitted_parameters, if: :devise_controller?

	def stripeInvoiceRequest(lineItems,connectAccountCus)
		params = {
			'lineItems' => lineItems,
			'connectAccountCus' => connectAccountCus,
			'connectAccount' => ENV['connectAccount'],
			'serviceFee' => @serviceFee, #add stripe fee from subitem total 
			# 'description' => "#{session[:gender].titleize}: #{session[:size]}", #no description for services
		}.to_json

    curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -d '#{params}' -X POST #{SITEurl}/v2/invoices`

	  response = Oj.load(curlCall)
	end

	def stripeCustomerRequest(token)
		connectAccountCus = Stripe::Customer.create({
			email: session[:email],
			name: session[:name],
			phone: session[:phone],
			address: session[:address],
		  source: token['id']
		}, {stripe_account: ENV['connectAccount']})

		return connectAccountCus
	end

	def stripeTokenRequest(newStripeCardTokenParams,connectAccount)
		number = newStripeCardTokenParams[:number]
    exp_year = newStripeCardTokenParams[:exp_year]
    exp_month = newStripeCardTokenParams[:exp_month]
    cvc = newStripeCardTokenParams[:cvc]

    if connectAccount.present?
	    curlCall = `curl -H "appName: #{ENV['appName']}" -d "connectAccount=#{connectAccount}&number=#{number}&exp_month=#{exp_month}&exp_year=#{exp_year}&cvc=#{cvc}" #{SITEurl}/v2/tokens`
	  else
	    curlCall = `curl -H "appName: #{ENV['appName']}" -d "number=#{number}&exp_month=#{exp_month}&exp_year=#{exp_year}&cvc=#{cvc}" #{SITEurl}/v2/tokens`
	  end

    response = Oj.load(curlCall)
	end

	def pullChargesAPI
		curlCall = current_user&.indexStripeChargesAPI(params)
			
	  response = Oj.load(curlCall)

    if response['success']
			session[:payments] = response['payments']
			session[:pending] = response['pending']
		elsif response['message'] == "No purchases found"
			@message = response['message']
		else
			flash[:error] = response['message']
		end
	end

	def grabCart
		if current_user&.authentication_token
			curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X GET #{SITEurl}/v1/carts`
			
	    response = Oj.load(curlCall)
	    
	    if response['success']
	    	@cart = response.merge(stripeCapturePercentage: ENV['stripeCapturePercentage'].to_f * 0.01, tenPercentDepositCoupon: ENV['tenPercentDepositCoupon'], thirtyPercentDepositCoupon: ENV['thirtyPercentDepositCoupon'], fiftyPercentDepositCoupon: ENV['fiftyPercentDepositCoupon'])
	    	session[:cart] = response.merge(coupon: !session[:coupon].blank? ? session[:coupon] : "" , stripeCapturePercentage: ENV['stripeCapturePercentage'].to_f * 0.01, tenPercentDepositCoupon: ENV['tenPercentDepositCoupon'], thirtyPercentDepositCoupon: ENV['thirtyPercentDepositCoupon'], fiftyPercentDepositCoupon: ENV['fiftyPercentDepositCoupon'])
	    	if @cart['carts'].present?
		    	@cartID = @cart['carts'][0]['cartID']
		    end
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
						@serviceFee =  !session[:coupon].blank? ? (@cart['serviceFee'] * (0.01 * (100-session[:percentOff]))).to_i : @cart['serviceFee']
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

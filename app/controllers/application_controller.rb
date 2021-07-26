class ApplicationController < ActionController::Base
	before_action :configure_permitted_parameters, if: :devise_controller?

	def stripeInvoiceRequest(lineItems,customer, serviceFee, connectAccount)

		paramsX = {
			"customer" => customer,
			"description" => "class bought",
			"amount" => @subtotal + @application_fee_amount + @stripeFee,
			"application_fee_amount" => @application_fee_amount
		}.to_json

    curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -d '#{paramsX}' -X POST #{SITEurl}/api/v2/invoices`
    
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
	    curlCall = `curl -H "appName: #{ENV['appName']}" -d "connectAccount=#{connectAccount}&number=#{number}&exp_month=#{exp_month}&exp_year=#{exp_year}&cvc=#{cvc}" #{SITEurl}/api/v2/tokens`
	  else
	    curlCall = `curl -H "appName: #{ENV['appName']}" -d "number=#{number}&exp_month=#{exp_month}&exp_year=#{exp_year}&cvc=#{cvc}" #{SITEurl}/api/v2/tokens`
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
			curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X GET #{SITEurl}/api/v1/carts`
			
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

	  	curlCall = `curl -H "appName: #{ENV['appName']}" -X GET #{SITEurl}/api/v1/carts?cartID=#{@cartID}`
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

	  @subtotal = @cart["subItemsTotal"]
		@application_fee_amount = (@subtotal * (ENV['serviceFee'].to_i * 0.01)).to_i
		@stripeFee = (((@subtotal+@application_fee_amount) * 0.03) + 30).to_i

	end

	private

	def newInvoiceParams
		paramsClean = params.require(:newInvoice).permit(:customer, :amount, :desc, :title)
	end

	protected
	def configure_permitted_parameters
	  devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :email, :password, :password_confirmation]) 
  end
end

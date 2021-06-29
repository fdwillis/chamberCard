class ApplicationController < ActionController::Base
	before_action :configure_permitted_parameters, if: :devise_controller?

	def stripeCheckoutRequest(lineItems,connectAccountCus)
		lineItems.each do |lineItem|
			stripePriceInfo = Stripe::Price.retrieve(lineItem[:price], {stripe_account: ENV['connectAccount']})
			stripeProductInfo = Stripe::Product.retrieve(stripePriceInfo[:product], {stripe_account: ENV['connectAccount']})

			if !stripeProductInfo.shippable
				inI = Stripe::InvoiceItem.create({
					currency: 'usd',
				  customer: connectAccountCus['id'],
				  description: stripeProductInfo[:name],
				  unit_amount_decimal: stripePriceInfo[:unit_amount_decimal],
				  quantity: lineItem[:quantity],
				  metadata: {
				  	price: stripePriceInfo[:id]
				  }
				}, {stripe_account: ENV['connectAccount']})


			else
				inI = Stripe::InvoiceItem.create({
					currency: 'usd',
				  customer: connectAccountCus['id'],
				  description: stripeProductInfo[:name],
				  unit_amount_decimal: stripePriceInfo[:unit_amount_decimal],
				  quantity: lineItem[:quantity],
				  metadata: {
				  	shipping: "true",
				  	pickup: "",
				  	price:  stripePriceInfo[:id]
				  }
				}, {stripe_account: ENV['connectAccount']})
			end
			# make one invoice with all line items? in v2 here
			appFeeAmount = ((stripePriceInfo[:unit_amount_decimal].to_i * lineItem[:quantity].to_i) * (ENV['serviceFee'].to_i * 0.01) ).to_i
			
			if session[:coupon]
				listInvoice = Stripe::Invoice.create({
					customer: connectAccountCus['id'],
					application_fee_amount: (appFeeAmount * (1 - (session[:percentOff] * 0.01))).to_i,
					discounts: [
						{coupon: session[:coupon]},
					],
					metadata: {
						goodOrService: stripeProductInfo.shippable == true ? 'good' : 'service',
						trackingNumbers: "",
				  	orderIssue: '',
				  	issueResolved: '',
					}
				}, {stripe_account: ENV['connectAccount']})
			else
				listInvoice = Stripe::Invoice.create({
					customer: connectAccountCus['id'],
					application_fee_amount: appFeeAmount,
					discounts: [
						{coupon: session[:coupon]},
					],
					metadata: {
						goodOrService: stripeProductInfo.shippable == true ? 'good' : 'service',
						trackingNumbers: "",
				  	orderIssue: '',
				  	issueResolved: '',
					}
				}, {stripe_account: ENV['connectAccount']})
			end

			openInvoice = Stripe::Invoice.finalize_invoice(listInvoice[:id], {}, {stripe_account: ENV['connectAccount']})
			payInvoice  = Stripe::Invoice.pay(listInvoice[:id], {}, {stripe_account: ENV['connectAccount']})
		  # email customer with receipt_email update via payment intent
		  # text owner with invoice id and ENV['connectAccount']
		  receiptEmailX = Stripe::PaymentIntent.update(
			  payInvoice['payment_intent'],{
			  	receipt_email: connectAccountCus['email'],
			  },
			  {stripe_account: ENV['connectAccount']},
			)
			
		  if ENV['stripeLivePublish'].include?("pk_live_")
			  textData = {
					'stripeMerchantID' => ENV['connectAccount'],
					'stripePaymentIntentID' => payInvoice['payment_intent'],
				}.to_json

			  notifyTwilio = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -d '#{textData}' -X POST #{SITEurl}/v1/twilioText`
	
		    response = Oj.load(notifyTwilio)
			end
		end
	end

	def stripeCustomerRequest(session, token)
		connectAccountCus = Stripe::Customer.create({
			email: session[:email],
			name: session[:name],
			phone: session[:phone],
		  source: token['id']
		}, {stripe_account: ENV['connectAccount']})

		return connectAccountCus
	end

	def stripeTokenRequest(newStripeCardTokenParams)
		number = newStripeCardTokenParams[:number]
    exp_year = newStripeCardTokenParams[:exp_year]
    exp_month = newStripeCardTokenParams[:exp_month]
    cvc = newStripeCardTokenParams[:cvc]

    if ENV['connectAccount'].present?
	    curlCall = `curl -H "appName: #{ENV['appName']}" -d "connectAccount=#{ENV['connectAccount']}&number=#{number}&exp_month=#{exp_month}&exp_year=#{exp_year}&cvc=#{cvc}" #{SITEurl}/v2/tokens`
	  else
	    curlCall = `curl -H "appName: #{ENV['appName']}" -d "number=#{number}&exp_month=#{exp_month}&exp_year=#{exp_year}&cvc=#{cvc}" #{SITEurl}/v2/tokens`
	  end

    response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
      return response['token']
    else
      return response['error']
    end
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

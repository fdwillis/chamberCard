class CheckoutController < ApplicationController
	def create
  	invoicesToPay = []
		
		if current_user&.authentication_token
			datax = session[:cart].to_json
			curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d '#{datax}' -X POST #{SITEurl}/v1/checkout`
			
	    response = Oj.load(curlCall)
	    
	    if response['success']
	    	session[:coupon] = nil
	    	session[:percentOff] = nil
	    	flash[:success] = "Purchase Complete"
	    	redirect_to pay_now_path
	    else
	    	flash[:error] = response['error']
	    	redirect_to carts_path
	    end
	  else
	  	begin
			  if !session[:lineItems].blank?

				  token = stripeTokenRequest(newStripeCardTokenParams)

				  connectAccountCus = stripeCustomerRequest()	

					connectAccountCus = Stripe::Customer.create({
						email: params[:checkout][:email],
						name: params[:checkout][:name],
						phone: session[:phone],
					  source: token['id']
					}, {stripe_account: ENV['connectAccount']})

					session[:lineItems].each do |lineItem|
						stripePriceInfo = Stripe::Price.retrieve(lineItem[:price], {stripe_account: ENV['connectAccount']})
						stripeProductInfo = Stripe::Product.retrieve(stripePriceInfo[:product], {stripe_account: ENV['connectAccount']})

						if !stripeProductInfo.shippable
							inI = Stripe::InvoiceItem.create({
								currency: 'usd',
							  customer: connectAccountCus,
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
							  customer: connectAccountCus,
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
								customer: connectAccountCus,
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
								customer: connectAccountCus,
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
					  invoicesToPay << payInvoice[:id]
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

					reset_session
					redirect_to request.referrer
					flash[:success] = "Purchase Complete"
					return


					
				else
					flash[:alert] = 'Add items to your cart'
					redirect_to carts_path
				end
			rescue Stripe::StripeError => e
				flash[:error] = e.error.message
				redirect_to carts_path
				return
			rescue Exception => e
				flash[:error] = e
				redirect_to carts_path
				return
			end
	  end
		
	end

	def success

		@sessionPaid = Stripe::Checkout::Session.retrieve(params[:session_id], {stripe_account: ENV['connectAccount']})

		@customerUpdated = Stripe::Customer.update(@sessionPaid.customer,{phone: session[:phone], address: session[:address]},{stripe_account: ENV['connectAccount']})

		@paymentCharge = Stripe::PaymentIntent.retrieve(@sessionPaid.payment_intent,{stripe_account: ENV['connectAccount']})

		# @paymentUpdated = Stripe::PaymentIntent.update(@sessionPaid.payment_intent,{metadata: {phone: '4144444444', address: '222 w washington madison wi 53703'}},{stripe_account: ENV['connectAccount']})
	
		@line_items = Stripe::Checkout::Session.list_line_items(@sessionPaid.id, {limit: 100}, {stripe_account: ENV['connectAccount']})['data']

		@collecctAnonFee = Stripe::Charge.create({
		  amount: @serviceFee,
		  currency: 'usd',
		  description: "#{ENV['appName']} Transaction Fee - ##{@paymentCharge.id} | TewCode",
		  source: ENV['connectAccount'],
		})

		# add anan user to platform as customer
		
		curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -X DELETE #{SITEurl}/v1/carts/#{@cartID}`

		response = Oj.load(curlCall)
	    
    if response['success']
			reset_session
    	flash[:success] = "Purchase Complete"
    else
    	flash[:error] = response['error']
    	redirect_to carts_path
    end
	end

	def cancel
		
	end
	private

	def newStripeCardTokenParams
		paramsClean = params.require(:checkout).permit(:number, :exp_year, :exp_month, :cvc)
		return paramsClean.reject{|_, v| v.blank?}
	end
end
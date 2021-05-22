class CheckoutController < ApplicationController
	def create
		params = session[:cart].to_json
		
		if current_user&.authentication_token
			curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d '#{params}' -X POST #{SITEurl}/v1/checkout`
			
	    response = Oj.load(curlCall)
	    
	    if response['success']
	    	flash[:success] = "Purchase Complete"
	    	redirect_to pay_now_path
	    else
	    	flash[:error] = response['error']
	    	redirect_to carts_path
	    end
	  else
	  	@checkoutAnon = Stripe::Checkout::Session.create({
			  success_url: success_url+'?session_id={CHECKOUT_SESSION_ID}',
			  cancel_url: carts_url,
			  payment_method_types: ['card'],
			  line_items: [session[:lineItems]],
			  mode: 'payment',
			}, stripe_account: ENV['connectAccount'])

			respond_to do |format|
				format.js
			end
	  end
		
	end

	def success

		@sessionPaid = Stripe::Checkout::Session.retrieve(params[:session_id], {stripe_account: ENV['connectAccount']})

		@paymentCharge = Stripe::PaymentIntent.retrieve(@sessionPaid.payment_intent,{stripe_account: ENV['connectAccount']})
		# edit payment intent for application fee @serviceFee
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
end
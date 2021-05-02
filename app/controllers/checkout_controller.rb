class CheckoutController < ApplicationController
	protect_from_forgery with: :null_session, only: [:checkout, :checkout_anon]

	def create
		params = @cart.to_json
		
		if current_user&.authentication_token
			curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d '#{params}' -X POST #{SITEurl}/v1/checkout`
			
	    response = Oj.load(curlCall)
	    
	    if response['success']
	    	flash[:success] = "Purchase Complete"
	    	redirect_to charges_path
	    else
	    	flash[:error] = response['error']
	    	redirect_to carts_path
	    end
	  else

	  	@checkoutAnon = Stripe::Checkout::Session.create({
			  success_url: success_url+'?session_id={CHECKOUT_SESSION_ID}',
			  cancel_url: carts_url,
			  payment_method_types: ['card'],
			  line_items: [@lineItems],
			  mode: 'payment',
			}, stripe_account: ENV['connectAccount'])

			respond_to do |format|
				format.js
			end
	  end
		
	end

	def success
		@cart = nil

		@sessionPaid = Stripe::Checkout::Session.retrieve(params[:session_id], stripe_account: ENV['connectAccount'])

		@paymentCharge = Stripe::PaymentIntent.retrieve(@sessionPaid.payment_intent,{stripe_account: ENV['connectAccount']})

		@collecctAnonFee = Stripe::Charge.create({
		  amount: @serviceFee,
		  currency: 'usd',
		  description: "Transaction Fee # #{@paymentCharge.id} | TewCode",
		  source: ENV['connectAccount'],
		})

		# add anan user to platform as customer
		
		curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -X DELETE #{SITEurl}/v1/carts/#{@cartID}`

		response = Oj.load(curlCall)
	    
    if response['success']
    	flash[:success] = "Purchase Complete"
    else
    	flash[:error] = response['error']
    	redirect_to carts_path
    end
	end

	def cancel
		
	end
end
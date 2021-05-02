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
			  success_url: carts_url,
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
end
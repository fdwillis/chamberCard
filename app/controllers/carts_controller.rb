class CartsController < ApplicationController

	def index
		
	end

	def update
		params = {
			'line_items' => [
				{
					'stripePriceID' => "price_#{cartParams['sellerItem'].split("-")[1]}",
				  'quantity' 			=> cartParams['quantity']
				}
			]
		}.to_json

		if current_user&.authentication_token
			curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d '#{params}' -X PATCH #{SITEurl}/v1/carts/#{grabID}`
			
			
	    response = Oj.load(curlCall)

	    if !response.blank? && response['success']
	    	flash[:success] = "Added to cart"
	    	redirect_to request.referrer
	    end
	  end
	end

	def show
		params = {
			'line_items' => [
				{
					'stripePriceID' => grabItem,
				}
			]
		}.to_json

		if current_user&.authentication_token
			curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d '#{params}' -X DELETE #{SITEurl}/v1/carts/#{grabID}`
			
	    response = Oj.load(curlCall)

	    if !response.blank? && response['success']
	    	flash[:alert] = "Removed From Cart"
	    	redirect_to request.referrer
	    end
	  end
	end

	private

	def cartParams
		params.require(:addToCart).permit(:sellerItem, :quantity)
	end

	def grabID
		params.require(:id)
	end

	def grabItem
		params.require(:item)
	end

end
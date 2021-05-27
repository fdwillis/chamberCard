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
		else	
			curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -d '#{params}' -X PATCH #{SITEurl}/v1/carts/#{grabID}?cartID=#{@cartID}`
	  end
			
	    response = Oj.load(curlCall)

	    if response['success']
	    	flash[:success] = "Added to cart"
	    	redirect_to request.referrer
	    end
	end

	def updateQuantity
		params = {
			'line_items' => [
				{
					'stripePriceID' => cartParams['sellerItem'],
				  'quantity' 			=> cartParams['quantity']
				}
			]
		}.to_json

		curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -d '#{params}' -X PATCH #{SITEurl}/v1/carts/#{grabID}?cartID=#{@cartID}`
		
		
    response = Oj.load(curlCall)

    if response['success']
    	flash[:success] = "Cart Updated"
    	redirect_to request.referrer
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

		curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -d '#{params}' -X DELETE #{SITEurl}/v1/carts/#{grabID}`
		
    response = Oj.load(curlCall)
    if response['success']
    	flash[:success] = "Removed from cart"
    	redirect_to request.referrer
    else
    	flash[:alert] = "Something went wrong"
    	redirect_to carts_path
    end
	end


	private

	def cartParams
		paramsClean = params.require(:addToCart).permit(:sellerItem, :quantity)
	end

	def grabID
		paramsClean = params.require(:id)
	end

	def grabItem
		paramsClean = params.require(:item)
	end

end
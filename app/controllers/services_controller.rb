class ServicesController < ApplicationController
	before_action :authenticate_user!, only: [:create, :update, :edit, :new]

	def index
		grabCart
		if current_user&.authentication_token
			curlCall = Product.APIindex(current_user)
		else
			curlCall = Product.APIindex(nil)
		end

    response = Oj.load(curlCall)
    if response['success']
			
			if @store = response['store']
				activeProducts = []
				unavailableProducts = []

				@store.each do |store|
					store['products'].each do |product|

						if product['type'] == 'service'
							if product['active'] == true && !Stripe::Price.list({limit: 100, product: product['id'], active: true}, {stripe_account: store['connectAccount']})['data'].blank?
								activeProducts << [product: product, connectAccount: store['connectAccount']]
							else
								unavailableProducts << [product: product, connectAccount: store['connectAccount']]
							end
						end
					end
				end
				
				@activeProducts = activeProducts.flatten
				@unavailableProducts = unavailableProducts.flatten
				@products = @activeProducts + @unavailableProducts
			end
		end
	end

	def show
		grabCart
		curlCall = Product.APIshow(params)
		response = Oj.load(curlCall)
		
		if !response['product'].blank? && response['success']
			@product = response['product']
			@connectAccount = response['connectAccount']
			@prices = response['prices']
		end
	end

	def create
		if current_user&.manager?

			curlCall = Product.APIcreate(current_user, productParams)

			response = Oj.load(curlCall)
			if response['success']
				flash[:success] = "Service Created"
				redirect_to services_path
			else
				flash[:alert] = response['message']
				redirect_to new_service_path
			end
		end
	end

	def update
		if current_user&.manager?
			curlCall = Product.APIupdate(current_user, productParams)
			response = Oj.load(curlCall)

			if response['success']
				
				flash[:success] = "Service Updated"
				redirect_to service_path(id: params[:id][5..params[:id].length], connectAccount: current_user&.stripeMerchantID)
			end
		end
	end

	def edit
		if !params['service'].blank?
			@product = params['service']
		else
			flash[:error] = "No product found"
			redirect_to request.referrer
		end
	end

	def new
	end

	private

	def productParams
		paramsClean = params.require(:product).permit(:id, :keywords, :connectAccount, :timeKitID, :name, :description, :type, :active, {images: []} )
		return paramsClean.reject{|_, v| v.blank?}
	end
end
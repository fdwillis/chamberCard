class ServicesController < ApplicationController
	before_action :authenticate_user!, except: :index

	def index
		if current_user&.authentication_token
			curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X GET #{SITEurl}/v1/products`
		else
			curlCall = `curl -H "appName: #{ENV['appName']}" -X GET #{SITEurl}/v1/products`
		end

    response = Oj.load(curlCall)

    if !response.blank? && response['success']
			
			if @store = response['store']
				activeProducts = []
				unavailableProducts = []

				@store.each do |store|
					store['products'].each do |product|
						if product['active'] == true && !Stripe::Price.list({limit: 100, product: product['id'], active: true}, {stripe_account: store['connectAccount']})['data'].blank?
							activeProducts << [product: product, connectAccount: store['connectAccount']]
						else
							unavailableProducts << [product: product, connectAccount: store['connectAccount']]
						end
					end
				end

				@activeProducts = activeProducts.flatten
				@unavailableProducts = unavailableProducts.flatten
			else
				# no products
			end
		else
			flash[:alert] = "Trouble connecting. Try again later."
			redirect_to new_user_session_path
		end
	end

	def show
		if current_user&.authentication_token
			curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X GET #{SITEurl}/v1/products/prod_#{params[:id]}?connectAccount=#{params[:connectAccount]}`
		else

		end
		
		response = Oj.load(curlCall)
		if !response['product'].blank? && response['success']
			@product = response['product']
			@connectAccount = response['connectAccount']
			@prices = response['prices']
		else
			flash[:alert] = "Trouble connecting. Try again later."
			redirect_to services_path
		end

	end

	def create
		if current_user&.manager?
			appName = ENV['appName']
			productName = productParams[:name]
			description = productParams[:description]
			type = productParams[:type]
			active = ActiveModel::Type::Boolean.new.cast(productParams[:active])
			connectAccount = ENV['connectAccount']

			images = []
			productStarted = Product.create(stripeProductID: response['product'])

			productParams['images'].each do |img|
				imageMade = productStarted.images.create(source: img)
				cloudX = Cloudinary::Uploader.upload(imageMade.source.file.file)
				images.append(cloudX['secure_url'])
			end
			

			curlCall = `curl -H "appName: #{ENV['appName']}" -d 'images=#{images.join(",")}&type=#{type}&name=#{productName}&description=#{description}&connectAccount=#{connectAccount}&active=#{active}' -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X POST #{SITEurl}/v1/products`
			response = Oj.load(curlCall)
			
		
			if !response.blank? && response['success']

				flash[:success] = "Service Created"
				redirect_to services_path
			else
				debugger
				flash[:alert] = response['message']
				redirect_to new_service_path
			end
		end
	end

	def update
		appName = ENV['appName']
		productName = params[:updateService][:name]
		description = params[:updateService][:description]
		type = params[:updateService][:type]
		active = ActiveModel::Type::Boolean.new.cast(params[:updateService][:active])
		connectAccount = ENV['connectAccount']


		curlCall = `curl -H "appName: #{ENV['appName']}" -d "name=#{productName}&description=#{description}&active=#{active}&type=#{type}&connectAccount=#{connectAccount}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X PATCH #{SITEurl}/v1/products/#{params[:id]}`
		
		response = Oj.load(curlCall)
		
		if !response.blank? && response['success']
			flash[:success] = "Service Updated"
			redirect_to service_path(id: params[:id], connectAccount: connectAccount)
			return
		else
			flash[:alert] = "Trouble connecting. Try again later."
		end
	end

	def destroy
		curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X DELETE #{SITEurl}/v1/time-slots/#{params[:id]}`
		
		response = Oj.load(curlCall)
		
		if !response.blank? && response['success']
			flash[:success] = "Service removed. No longer for sale"
			redirect_to services_path
		else
			flash[:alert] = "Trouble connecting. Try again later."
			redirect_to services_path
		end
	end

	def edit
		if !params['product'].blank?
			@product = params['product']
		else
			flash[:error] = "No product found"
			redirect_to request.referrer
		end
	end

	def new
	end

	private

	def productParams
		paramsClean = params.require(:product).permit(:name, :description, :type, :active, {images: []})
	end
end
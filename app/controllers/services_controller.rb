class ServicesController < ApplicationController
	before_action :authenticate_user!, except: :index

	def index
		if current_user&.authentication_token
			curlCall = Service.APIindex(current_user)
		else
			curlCall = Service.APIindex(nil)
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
		else
			flash[:alert] = "Trouble connecting. Try again."
			redirect_to new_user_session_path
		end
	end

	def show
		if current_user&.authentication_token
			curlCall = Service.APIshow(current_user, params)
		
			response = Oj.load(curlCall)
			
			if !response['product'].blank? && response['success']
				@product = response['product']
				@connectAccount = response['connectAccount']
				@prices = response['prices']
			else
				flash[:alert] = "Trouble connecting. Try again."
				redirect_to services_path
			end
		else
			redirect_to new_user_session_path
			flash[:alert] = 'Please login'
		end

	end

	def create
		if current_user&.manager?

			curlCall = Service.APIcreate(current_user, productParams)

			response = Oj.load(curlCall)

			if response['success']
				flash[:success] = "Service Created"
				redirect_to services_path
			else
				productStarted.destroy!
				flash[:alert] = response['message']
				redirect_to new_service_path
			end
		end
	end

	def update
		# appName = ENV['appName']
		# productName = productParams[:name]
		# description = productParams[:description]
		# type = productParams[:type]
		# keywords = productParams[:keywords]
		# active = ActiveModel::Type::Boolean.new.cast(productParams[:active])
		# connectAccount = ENV['connectAccount']

		# images = []


		# if !productParams['images'].blank?
		# 	productParams['images'].each do |img|
		# 		productFound = Product.find_by(stripeProductID: params[:id])
		# 		imageMade = productFound.images.create(source: img)
				
		# 		cloudX = Cloudinary::Uploader.upload(imageMade.source.file.file)
		# 		images.append(cloudX['secure_url'])
		# 		File.delete(imageMade.source.file.file)
		# 	end
		# end


		if current_user&.manager?
			curlCall = Service.APIupdate(current_user, productParams)
			response = Oj.load(curlCall)

			if response['success']
				
				flash[:success] = "Service Updated"
				redirect_to service_path(id: params[:id][5..params[:id].length], connectAccount: current_user&.stripeMerchantID)
			else
				flash[:alert] = "Trouble connecting. Try again."
				redirect_to request.referrer
			end
		end
	end

	def destroy
		curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X DELETE #{SITEurl}/v1/time-slots/#{params[:id]}`
		
		response = Oj.load(curlCall)
		
		if response['success']
			flash[:success] = "Service removed. No longer for sale"
			redirect_to services_path
		else
			flash[:alert] = "Trouble connecting. Try again."
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
		paramsClean = params.require(:product).permit(:id, :name, :description, :type, :active, {images: []}, :keywords, :connectAccount)
		return paramsClean.reject{|_, v| v.blank?}
	end
end
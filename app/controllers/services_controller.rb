class ServicesController < ApplicationController
	def index
		
		if current_user&.authentication_token
			curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X GET #{SITEurl}/v1/products`
		else
			curlCall = `curl -H "appName: #{ENV['appName']}" -X GET #{SITEurl}/v1/products`
		end

    response = Oj.load(curlCall)

    if !response.blank? && response['success']
			if @products = response['products']

				@activeProducts = []
				@unavailableProducts = []

				if current_user && current_user&.manager?
					@products['data'].each do |product|
						if product['active'] == true
							@activeProducts << product
						else
							@unavailableProducts << product
						end
					end
				else
					@products.each do |product|
						if product['stripePriceInfo']['active'] == true
							
							@activeProducts << product['stripePriceInfo']
						else
							@unavailableProducts << product['stripePriceInfo']
						end
					end
				end


				
			else
				# no products
			end
		else
			flash[:alert] = "Trouble connecting. Try again later."
			redirect_to new_user_session_path
		end
	end

	def show
		curlCall = `curl -X GET #{SITEurl}/v1/products/#{params[:id]}`
		
		response = Oj.load(curlCall)
		
		if !response['product'].blank? && response['success']
			@product = response['product']
		else
			flash[:alert] = "Trouble connecting. Try again later."
			redirect_to services_path
		end

	end

	def create

		if current_user&.manager?
			appName = ENV['appName']
			productName = params[:newService][:name]
			description = params[:newService][:description]
			type = params[:newService][:type]
			connectAccount = ENV['connectAccount']


			curlCall = `curl -d "appName=#{appName}&name=#{productName}&description=#{description}&active=#{ActiveModel::Type::Boolean.new.cast(params[:newService][:active])}&type=#{type}&connectAccount=#{connectAccount}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X POST #{SITEurl}/v1/products`
			
			response = Oj.load(curlCall)
		
			if !response.blank? && response['success']
				flash[:success] = "Service Created"
				redirect_to services_path
			else
				flash[:alert] = response['message']
				redirect_to new_service_path
			end
		end
	end

	def update
		cost = params[:updateService][:cost]
		title = params[:updateService][:title]
		desc = params[:updateService][:desc]


		curlCall = `curl -d "desc=#{desc}&cost=#{cost}&title=#{title}&" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X PATCH #{SITEurl}/v1/time-slots/#{params[:id]}`
		
		response = Oj.load(curlCall)
		
		if !response.blank? && response['success']
			flash[:success] = "Service Updated"
			redirect_to services_path
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
		show
	end

	def new
	end
end
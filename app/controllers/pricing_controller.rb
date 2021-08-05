class PricingController < ApplicationController
	before_action :authenticate_user!
	before_action :grabProduct

	def index
		# showing all prices for one product
		if current_user&.authentication_token
			curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X GET #{SITEurl}/api/v1/products/prod_#{!productParams.blank? ? productParams[:product_id] : serviceParams[:service_id]}/pricing`
		
			response = Oj.load(curlCall)

			if !response['product'].blank? && response['success']
				@prices = response['prices']
				@productL = response['product']
				@archived = response['archived']
			else
				flash[:alert] = "Trouble connecting..."
				redirect_to services_path
			end
		end

	end

	def show
	end

	def new
		
	end

	def create
		if !pricingParams['unit_amount'].blank?
			if current_user&.authentication_token
				
				params = {
					'product' => "prod_#{pricingParams[:product]}",
					'unit_amount' => stripeAmount(pricingParams['unit_amount']),
					'connectAccount' => current_user.stripeMerchantID,
					'package?' => ActiveModel::Type::Boolean.new.cast(pricingParams['package']),
					'divide_by' => pricingParams['divide_by'],
					'description' => pricingParams['description'],
					'public' => ActiveModel::Type::Boolean.new.cast(pricingParams['public']),
					
				}.to_json
				
				curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d '#{params}' -X POST #{SITEurl}/api/v1/products/prod_#{pricingParams[:product]}/pricing`


				response = Oj.load(curlCall)

				if response['success']
					flash[:success] = "Pricing Added"
					redirect_to request.referrer
					# redirect_to pricing_index_path(service_id: @productL['id'][5..@productL['id'].length])
				else
					flash[:alert] = "Trouble connecting..."
					redirect_to request.referrer
				end
			end
		else
			redirect_to request.referrer
			flash[:error] = "Price is required"
		end
	end

	def edit
		@price = params['price']
	end

	def update

		if current_user&.authentication_token
			
			params = {
				'product' => "prod_#{pricingParams[:product]}",
				'connectAccount' => current_user.stripeMerchantID,
				'package?' => ActiveModel::Type::Boolean.new.cast(pricingParams['package']),
				'divide_by' => pricingParams['divide_by'],
				'description' => pricingParams['description'],
				'active' => pricingParams['active'],
				'public' => ActiveModel::Type::Boolean.new.cast(pricingParams['public']),
			}.to_json

			curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d '#{params}' -X PATCH #{SITEurl}/api/v1/products/#{pricingParams[:product]}/pricing/#{serviceParams[:id]}`

			response = Oj.load(curlCall)

			if response['success']
				flash[:success] = "Pricing Updated"
			  redirect_to pricing_index_path(service_id: pricingParams[:product][5..pricingParams[:product].length])
			else
				flash[:alert] = "Trouble connecting..."
				redirect_to request.referrer
			end
		end
	end

	def grabProduct
		curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X GET #{SITEurl}/api/v1/products/prod_#{!productParams[:product_id].blank? ? productParams[:product_id] : serviceParams[:service_id]}?connectAccount=#{current_user.stripeMerchantID}`
		response = Oj.load(curlCall)

		if !response['product'].blank? && response['success']
			@productL = response['product']
		end
	end

	private

	def pricingParams
		paramsClean = params.require(:newPricing).permit(:service_id, :product_id, :id, :unit_amount, :product, :connectAccount, :package, :divide_by, :description, :active, :public)
		return paramsClean.reject{|_, v| v.blank?}
	end

	def serviceParams
		paramsClean = params.permit(:service_id, :id)
		return paramsClean.reject{|_, v| v.blank?}
	end

	def productParams
		paramsClean = params.permit(:product_id, :id)
		return paramsClean.reject{|_, v| v.blank?}
	end


end
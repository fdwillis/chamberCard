class PricingController < ApplicationController

	before_action :grabProduct

	def index
		# showing all prices for one product
		
		if current_user&.authentication_token
			curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X GET #{SITEurl}/v1/products/prod_#{params[:service_id]}/pricing`
		else

		end
		
		response = Oj.load(curlCall)

		if !response['product'].blank? && response['success']
			@prices = response['prices']
			# debugger
		else
			flash[:alert] = "Trouble connecting. Try again later."
			redirect_to services_path
		end

	end

	def show
	end

	def new
		
	end

	def create

		if !pricingParams['unit_amount'].blank?
			debugger

			params = {
				'product' => '',
				'unit_amount' => '',
				'connectAccount' => '',
				'package?' => '',
			}.to_json
		else
			redirect_to request.referrer
			flash[:error] = "Price is required"
		end
	end

	def edit
		
	end

	def update
		
	end

	def destroy
		
	end

	def grabProduct
		curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X GET #{SITEurl}/v1/products/prod_#{params[:service_id]}?connectAccount=#{current_user.stripeUserID}`
		response = Oj.load(curlCall)

		if !response['product'].blank? && response['success']
			@productL = response['product']
		end
	end

	private

	def pricingParams
		paramsClean = params.require(:newPricing).permit(:unit_amount,:product, :connectAccount, :package, :divide_by)
		return paramsClean.reject{|_, v| v.blank?}
	end


end
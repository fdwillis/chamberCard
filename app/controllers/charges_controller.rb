class ChargesController < ApplicationController
	def index
		if current_user&.authentication_token
			curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "" -X GET #{SITEurl}/v1/charges`
			
	    response = Oj.load(curlCall)
				
	    
	    if !response.blank? && response['success']
				@payments = response['payments']
				@overdue = response['overdue']
			elsif response['message'] == "No purchases found"
				@message = response['message']
			else
				flash[:error] = response['message']
			end
		end
	end

	def new
		@title = params[:title]
		@uuid = params[:uuid]
		@desc = params[:desc]
	end

	def create
		timeSlot = params[:newCharge][:uuid]
		quantity = params[:newCharge][:quantity]
		desc = params[:newCharge][:desc]
    
    curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "quantity=#{quantity}&timeSlot=#{timeSlot}&timeSlotCharge=true&description=#{desc}" #{SITEurl}/v1/charges`

		response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
			flash[:success] = "Purchase successful"
      redirect_to service_path(id: timeSlot)
    else
			flash[:error] = response['error']
      redirect_to service_path(id: timeSlot)
    end

	end

	def initiateCharge
		if request.post?
			uuid = params[:initiateCharge][:customerID]
			curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "" -X GET #{SITEurl}/v1/users/#{uuid}`
				
	    response = Oj.load(curlCall)
	    
	    if !response.blank? && response['success']
				redirect_to getinitiateCharge_path(customerUUID: uuid)
			else
				flash[:error] = response['message']
				redirect_to charges_path
			end
		end
	end


	def newInvoice
		customer = params[:newInvoice][:customer]
		amount = params[:newInvoice][:amount]
		desc = params[:newInvoice][:desc]
		title = params[:newInvoice][:title]
    
    curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "customer=#{customer}&title=#{title}&desc=#{desc}&managerInvoice=true&amount=#{amount}" -X POST #{SITEurl}/v1/stripe-charges`

		response = Oj.load(curlCall)

    if !response.blank? && response['success']
			
			flash[:success] = "Invoice Created"
      redirect_to charges_path
    else
			flash[:error] = response['message']
      redirect_to charges_path
    end
	end

	def acceptInvoice
		charge = params[:stripeChargeID]
		
    curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X PATCH #{SITEurl}/v1/stripe-charges/#{charge}`

		response = Oj.load(curlCall)

    if !response.blank? && response['success']
			flash[:notice] = "Invoice Paid"
			
      redirect_to charges_path
    else
			flash[:error] = response['message']
      redirect_to charges_path
    end
		
	end
end
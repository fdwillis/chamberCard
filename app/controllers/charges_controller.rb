class ChargesController < ApplicationController
	def index
		if current_user.present?
			curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "" -X GET #{SITEurl}/v1/stripe-charges`
			
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
    
    curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "quantity=#{quantity}&timeSlot=#{timeSlot}&timeSlotCharge=true&description=#{desc}" #{SITEurl}/v1/stripe-charges`

		response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
			flash[:success] = "Purchase successful"
      redirect_to service_path(id: timeSlot)
    else
			flash[:error] = response['error']
      redirect_to service_path
    end

	end
end
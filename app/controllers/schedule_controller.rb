class ScheduleController < ApplicationController
	def index
		if current_user.present?
			curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "" -X GET #{SITEurl}/v1/available-times`

	    response = Oj.load(curlCall)
	    
	    if !response.blank? && response['success']
				@timeBought = response['timeBought']
				@availableTimes = response['availableTimes']
				@bookingRequests = response['bookingRequests']
			elsif response['message'] == "Invalid Token"
				flash[:alert] = "To authorize your account, logout then login again."
			else
				flash[:alert] = "Trouble connecting. Try again later."
			end
		end
	end

	def cancel
		# canceling session
		cancelIt = params[:cancel][:uuid]
		curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "" -X PATCH #{SITEurl}/v1/available-times/#{cancelIt}/cancel`
    
    response = Oj.load(curlCall)
		
		if !response.blank? && response['success']
			flash[:alert] = response['message']
			redirect_to request.referrer
		elsif response['message'] == "Invalid Token"
			flash[:alert] = "To authorize your account, logout then login again."
		else
			flash[:alert] = "Trouble connecting. Try again later."
		end
	end
end
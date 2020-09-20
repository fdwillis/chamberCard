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
				flash[:notice] = "To authorize your account, logout then login again."
			else
				flash[:notice] = "Trouble connecting. Try again later."
			end
		end
	end
end
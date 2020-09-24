class ServicesController < ApplicationController
	def index
		
		if current_user&.authentication_token
			curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X GET #{SITEurl}/v1/time-slots`
		else
			curlCall = `curl -X GET #{SITEurl}/v1/time-slots`
		end

    response = Oj.load(curlCall)

    if !response.blank? && response['success']
			@hourlies = response['hourlies']
			@services = response['services']
			# debugger
			@residential = response['residential']
			@business = response['business']
		else
			flash[:alert] = "Trouble connecting. Try again later."
			redirect_to new_user_session_path
		end
	end

	def show
		curlCall = `curl -X GET #{SITEurl}/v1/time-slots/#{params[:id]}`
		
		response = Oj.load(curlCall)
		
		if !response.blank? && response['success']
			@slot = response['timeSlot']
		else
			flash[:alert] = "Trouble connecting. Try again later."
		end
	end
end
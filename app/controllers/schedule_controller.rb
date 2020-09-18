class ScheduleController < Devise::RegistrationsController
	def index
		curlCall = `curl -d "" -X GET #{SITEurl}/v1/time-slots`

    response = Oj.load(curlCall)

    if !response.blank? && response['success']
			@hourlies = response['hourlies']
			@services = response['services']
			@products = response['products']
			
		else
			flash[:notice] = "Trouble connecting. Try again later."
			redirect_to new_user_session_path
		end
	end
end
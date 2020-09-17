class ServicesController < Devise::RegistrationsController
	def index
		curlCall = `curl -d "" -X GET #{SITEurl}/v1/time-slots`

    response = Oj.load(curlCall)

    if response['success']
			@hourlies = response['hourlies']
			@services = response['services']
			@products = response['products']
			
		else
			flash[:notice] = "Trouble connecting"
			redirect_to root_path
		end
	end
end
class ServicesController < ApplicationController
	def index
		
		if current_user&.authentication_token
			curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X GET #{SITEurl}/v1/time-slots`
		else
			curlCall = `curl -H "appName: #{ENV['appName']}" -X GET #{SITEurl}/v1/time-slots`
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

	def create

		if current_user&.manager?
			cost = params[:newService][:cost].to_f
			title = params[:newService][:title]
			desc = params[:newService][:desc]
			appName = ENV['appName']

			if residentialBusiness = params[:newService][:residentialBusiness]
				 residentialBusiness == 'residential' ? residentialBusiness : residentialBusiness = 'business'

				 if residentialBusiness == 'business'
				 	resOrBiz = "business?=true&"
				 end

				 if residentialBusiness == 'residential'
				 	resOrBiz = "residential?=true&"
				 end
			end

			if servicePackage = params[:newService][:servicePackage]
				servicePackage == 'service' ? servicePackage : servicePackage = 'package'

				 if servicePackage == 'package'
				 	servOrPack = "package?=true&"
				 end

				 if servicePackage == 'service'
				 	servOrPack = "service?=true&"
				 end
			end

			approverID = current_user.uuid
			approved = true
			
			curlCall = `curl -d "cost=#{cost}&#{servOrPack}approverID=#{approverID}&#{resOrBiz}title=#{title}&desc=#{desc}&appName=#{appName}&approved?=#{approved}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X POST #{SITEurl}/v1/time-slots`
			
			response = Oj.load(curlCall)
		
			if !response.blank? && response['success']
				flash[:success] = "Service Created"
				redirect_to services_path
			else
				flash[:alert] = response['message']
				redirect_to new_services_path
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
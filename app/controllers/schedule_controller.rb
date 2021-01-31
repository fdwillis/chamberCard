class ScheduleController < ApplicationController
	before_action :authenticate_user!
	
	def index
		if current_user&.authentication_token
			curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "" -X GET #{SITEurl}/v1/charges`
			
	    response = Oj.load(curlCall)
				
	    if !response.blank? && response['success']
				@payments = response['payments']
			elsif response['message'] == "No purchases found"
				@message = response['message']
			else
				flash[:error] = response['message']
			end
		else
			current_user = nil
      reset_session
		end
	end

	def confirm
		# canceling session

		confirm = params[:confirm][:serviceToConfirm]
		merchantStripeID = params[:confirm][:merchantStripeID]

		curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}"   -d 'confirm=#{confirm}&merchantStripeID=#{merchantStripeID}' -X POST #{SITEurl}/v1/booking-accept`
    
    response = Oj.load(curlCall)
		
		if !response.blank? && response['success']
			flash[:alert] = response['message']
			redirect_to request.referrer
		else
			flash[:alert] = "Trouble connecting. Try again later."
		end
	end

	def cancel
		# canceling session
		debugger
		# return

		cancelIt = params[:cancel][:serviceToCancel]
		curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "serviceToCancel=#{cancelIt}" -X POST #{SITEurl}/v1/booking-cancel`
    
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

	def acceptBooking
		# sync booking to manager calendar
		serviceToAccept = params[:acceptBooking][:serviceToAccept]
		
    curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d 'serviceToAccept=#{serviceToAccept}' -X POST #{SITEurl}/v1/booking-request`

		response = Oj.load(curlCall)

    if !response.blank? && response['success']
			flash[:success] = "Booking Scheduled"
			
      redirect_to request.referrer
    else
			flash[:error] = response['message']
      redirect_to request.referrer
    end
		
	end

	def requestBooking
		if request.post?
			serviceToBook = params[:requestBooking][:serviceToBook]

			year = params[:requestBooking]["dateRequested(1i)"]
			month = params[:requestBooking]["dateRequested(2i)"]
			day = params[:requestBooking]["dateRequested(3i)"]

			hour = params[:requestBooking]["my_time(4i)"]
			minute = params[:requestBooking]["my_time(5i)"]

			buildDate = "#{year}/#{month}/#{day} #{hour}:#{minute}"
			if !year.blank? && !month.blank? && !day.blank?
				dateRequested = params[:requestBooking][:dateRequested]
				merchantStripeID = params[:requestBooking][:merchantStripeID]
				
				curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}"  -d 'serviceToBook=#{serviceToBook}&dateRequested=#{buildDate}&merchantStripeID=#{merchantStripeID}' -X POST #{SITEurl}/v1/booking-request`
			else
				flash[:error] = "Something was missing"
				redirect_to request.referrer
				return
			end

	    response = Oj.load(curlCall)

	    if !response.blank? && response['success']
				flash[:success] = "Request Submitted"
				redirect_to request.referrer
			else
				flash[:error] = "Something went wrong"
				redirect_to request.referrer
			end
		end
	end
end
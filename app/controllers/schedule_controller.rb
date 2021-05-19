class ScheduleController < ApplicationController
	before_action :authenticate_user!, except: :timeKitCancel

	protect_from_forgery with: :null_session, only: :timeKitCancel
	
	def index
		if current_user&.authentication_token
			curlCall = current_user&.indexStripeScheduleAPI(params)
				
    	response = Oj.load(curlCall)
	    if response['success']
				@actualCharges = response['actualCharges']
				@hasMore = response['has_more']
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

	def create

		paramsX = scheduleServiceParams.to_json
		curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user&.authentication_token}" -d '#{paramsX}' -X POST #{SITEurl}/v1/schedules`
		response = Oj.load(curlCall)

    if response['success']
			flash[:success] = "Service Confirmed"
			
      redirect_to request.referrer
    else
			flash[:error] = response['message']
      redirect_to request.referrer
    end
	end
	
	def acceptBooking
		# sync booking to manager calendar
		bookingDone = current_user&.syncTimekit(params[:acceptBooking])
		if bookingDone[:success]

			curlCall = Schedule.APIaccept(current_user, params[:acceptBooking], bookingDone[:timeKitBookingID])

			response = Oj.load(curlCall)

	    if response['success']
				flash[:success] = "Booking Scheduled"
				
	      redirect_to request.referrer
	    else
				flash[:error] = response['message']
	      redirect_to request.referrer
	    end
		else
			flash[:error] = "Please don't double book: #{bookingDone[:message]}"
      redirect_to request.referrer
		end
	end

	def requestBooking
		if request.post?

			curlCall = Schedule.APIrequest(current_user, params[:requestBooking])

	    response = Oj.load(curlCall)

	    if response['success']
				flash[:success] = "Request Submitted"
				redirect_to request.referrer
			else
				flash[:error] = "Something went wrong"
				redirect_to request.referrer
			end
		end
	end

	private

	def scheduleServiceParams
		paramsClean = params.require(:scheduleService).permit(:sessionOrInvoiceID)
		return paramsClean.reject{|_, v| v.blank?}
	end
end
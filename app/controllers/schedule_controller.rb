class ScheduleController < ApplicationController
	before_action :authenticate_user!, except: :timeKitCancel

	protect_from_forgery with: :null_session, only: :timeKitCancel

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
	
	def index
		if current_user&.authentication_token
				chargesNcustomers

			if !session[:invoices].blank?
				@invoices = session[:invoices]
				@pending = session[:pending]
				@customerCharges = session[:customerCharges] #edit lineItems meta for scheduling
				
				if session[:charges].blank?
					anonCharges = []

					session[:charges].each do |anon|
						
						if anon['lineItems'].map{|litm| Stripe::Product.retrieve(litm['price']['product'], {stripe_account: ENV['connectAccount']})['type'] }.include?("service")
							anonCharges << anon
						end
					end
					session[:charges] = anonCharges
					@anonCharges = session[:charges] #edit stripe session meta for scheduling
				else
					@anonCharges = session[:charges] #edit stripe session meta for scheduling
				end
			end
		else
			current_user = nil
      reset_session
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
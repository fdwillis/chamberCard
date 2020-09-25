class BookItController < ApplicationController
before_action :authenticate_user!

	def create
		timeSlot = claimSlotParams[:timeSlot]
		stripeChargeID = claimSlotParams[:stripeChargeID]

		curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "timeSlot=#{timeSlot}&stripeChargeID=#{stripeChargeID}&purchase=true" -X PATCH #{SITEurl}/v1/available-times/#{claimSlotParams[:timeToBook]}`
		
		response = Oj.load(curlCall)
	    
    if !response.blank? && response['success']
    	flash[:success] = "Successfully Booked"
    	redirect_to schedule_index_path
    else
    	flash[:error] = "Something went wrong"
    end
	end
	
	def bookingRequest
		# 2025-05-05 00:00:00 -0500

		date = "#{params[:bookIt][:yearSelect]}/#{params[:bookIt][:monthSelect]}/#{params[:bookIt][:daySelect]} #{params[:bookIt][:startHour]}:#{params[:bookIt][:startMinute]}:00"
		parsedDate = DateTime.parse(date)

		startTime = parsedDate
		endTime = parsedDate + 1.hour
		paidBy = current_user.uuid
		stripeChargeID = params[:bookIt][:stripeChargeID]
		timeSlot = params[:bookIt][:timeSlot]

		curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "appName=#{ENV['appName']}&endTime=#{endTime}&startTime=#{startTime}&timeSlot=#{timeSlot}&stripeChargeID=#{stripeChargeID}&paidBy=#{paidBy}" -X POST #{SITEurl}/v1/booking-request`
		
		response = Oj.load(curlCall)
	    
    if !response.blank? && response['success']
    	flash[:success] = "Request Submitted"
    	redirect_to schedule_index_path
    else
    	flash[:error] = "Something went wrong"
    end

	end

	def new
		if @timeBought = params[:timeBought]
		else
			flash[:alert] = "Please choose a service to book"
			redirect_to schedule_index_path
		end
	end

	def edit
		new
	end


	private

	def claimSlotParams
		params.require(:bookIt).permit(:timeSlot, :stripeChargeID, :timeToBook, :purchase)
	end
end
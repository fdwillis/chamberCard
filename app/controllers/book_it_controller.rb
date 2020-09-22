class BookItController < ApplicationController
before_action :authenticate_user!

	def create
		timeSlot = claimSlotParams[:timeSlot]
		stripeChargeID = claimSlotParams[:stripeChargeID]

		curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "timeSlot=#{timeSlot}&stripeChargeID=#{stripeChargeID}&purchase=true" -X PATCH #{SITEurl}/v1/available-times/#{claimSlotParams[:timeToBook]}`
		
		response = Oj.load(curlCall)
	    
    if !response.blank? && response['success']
    	flash[:success] = "Successfully Booked"
    	redirect_to schedule_path
    else
    	flash[:error] = "Something went wrong"
    end
	end

	def new
		if @timeBought = params[:timeBought]
		else
			flash[:alert] = "Please choose a service to book"
			redirect_to schedule_path
		end
	end

	def bookingRequest
		debugger
	end

	private

	def claimSlotParams
		params.require(:bookIt).permit(:timeSlot, :stripeChargeID, :timeToBook, :purchase)
	end
end
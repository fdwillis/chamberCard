class BookItController < ApplicationController
before_action :authenticate_user!

	def create
		timeSlot = claimSlotParams[:timeSlot]
		stripeCharge = claimSlotParams[:stripeCharge]

		curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "timeSlot=#{timeSlot}&stripeCharge=#{stripeCharge}&purchase=true" -X PATCH #{SITEurl}/v1/available-times/#{claimSlotParams[:timeToBook]}`
		
		response = Oj.load(curlCall)
	    
		debugger
    if !response.blank? && response['success']
    	flash[:success] = "Successfully Booked"
    	redirect_to schedule_path
    else
    	flash[:error] = "Something went wrong"
    end
	end

	def new
		@timeBought = params[:timeBought]
	end

	private

	def claimSlotParams
		params.require(:bookIt).permit(:timeSlot, :stripeCharge, :timeToBook, :purchase)
	end
end
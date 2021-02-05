class Schedule < ApplicationRecord
	def self.APIaccept(userX, params, timeKitID)
		if userX&.class == User
			
			serviceToAccept = params[:serviceToAccept]
			merchantStripeID = params[:merchantStripeID]
			
	    return `curl -H "bxxkxmxppAuthtoken: #{userX&.authentication_token}" -d 'timeKitBookingID=#{timeKitID}&serviceToAccept=#{serviceToAccept}&merchantStripeID=#{merchantStripeID}' -X POST #{SITEurl}/v1/booking-request`
		end
	end

	def self.APIrequest(userX, params)
		if userX&.class == User

			serviceToBook = params[:serviceToBook]

			year = params["dateRequested(1i)"]
			month = params["dateRequested(2i)"]
			day = params["dateRequested(3i)"]

			hour = params["my_time(4i)"]
			minute = params["my_time(5i)"]

			buildDate = "#{year}-#{month}-#{day} #{hour}:#{minute}"
			if !year.blank? && !month.blank? && !day.blank?
				dateRequested = params[:dateRequested]
				merchantStripeID = params[:merchantStripeID]
				
				return `curl -H "bxxkxmxppAuthtoken: #{userX&.authentication_token}"  -d 'serviceToBook=#{serviceToBook}&dateRequested=#{buildDate}&merchantStripeID=#{merchantStripeID}' -X POST #{SITEurl}/v1/booking-request`
			else
				return {success: false, message: "Something was missing"}
			end
		end
	end
end
class ChargesController < ApplicationController
	def index
		if current_user.present?
			curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "" -X GET #{SITEurl}/v1/stripe-charges`

	    response = Oj.load(curlCall)
	    
	    if !response.blank? && response['success']
				@payments = response['payments']
				@overdue = response['overdue']
			elsif response['message'] == "No purchases found"
				flash[:alert] = response['message']
			else
				flash[:error] = response['message']
			end
		end
	end
end
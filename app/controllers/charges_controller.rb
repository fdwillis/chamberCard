class ChargesController < ApplicationController
	def index
		if current_user.present?
			curlCall = `curl -d "" -X GET #{SITEurl}/v1/stripe-charges`

	    response = Oj.load(curlCall)
	    if !response.blank? && response['success']
				@payments = response['payments']
				@overdue = response['overdue']
			else
				flash[:notice] = response['success']
			end
		end
	end
end
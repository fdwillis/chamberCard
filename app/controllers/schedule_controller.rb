class ScheduleController < ApplicationController
	before_action :authenticate_user!, except: :timeKitCancel

	protect_from_forgery with: :null_session, only: :timeKitCancel
	
	def index
		if current_user&.authentication_token
			curlCall = current_user&.indexStripeScheduleAPI(params)
				
    	response = Oj.load(curlCall)
	    if response['success']
				@services = response['services']
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

	private

	def scheduleServiceParams
		paramsClean = params.require(:scheduleService).permit(:sessionOrInvoiceID)
		return paramsClean.reject{|_, v| v.blank?}
	end
end
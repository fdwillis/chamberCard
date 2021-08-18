class ScheduleController < ApplicationController
	before_action :authenticate_user!, except: :timeKitCancel

	protect_from_forgery with: :null_session, only: :timeKitCancel
	
	def index
		if current_user&.authentication_token
				
			@services = session[:fetchedPendingServices]
			@hasMore = session[:pendingServicesHasMore]

		else
			current_user = nil
      reset_session
		end
	end

	def create

		paramsX = scheduleServiceParams.to_json
		curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user&.authentication_token}" -d '#{paramsX}' -X POST #{SITEurl}/api/v1/schedules`
		response = Oj.load(curlCall)

    if response['success']
			flash[:success] = "Service Confirmed"
			session[:fetchedPendingServices].delete_if{|s| s['invoiceOrSessionID'] == params['scheduleService']['sessionOrInvoiceID']}
      redirect_to request.referrer
    else
			flash[:error] = response['message']
      redirect_to request.referrer
    end
	end

	private

	def scheduleServiceParams
		paramsClean = params.require(:scheduleService).permit(:sessionOrInvoiceID)
		return paramsClean.reject{|_, v| v.blank?}
	end
end
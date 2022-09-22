class ChargesController < ApplicationController
	before_action :authenticate_user!
	include ActionView::Helpers::DateHelper
	
	def payments
		if current_user&.authentication_token
			@customerPayments = session[:fetchedCharges].select{|ch| ch['customer'] == params['id']}
			@hasMore = session[:chargesHasMore]
			
		else
			current_user = nil
      reset_session
		end
	end
	
	def index
		if current_user&.authentication_token
			sleep 3
			curlCall = current_user&.indexStripeChargesAPI(params)
			response = Oj.load(curlCall)

		  if response['success']
		  	pullSource
				@payments = response['deposits'] #edit stripe session meta for scheduling
				@available = response['available'] #edit stripe session meta for scheduling
				@depositTotal = response['depositTotal'] #edit stripe session meta for scheduling
				@invested = response['invested'] #edit stripe session meta for scheduling
				@hasMore = response['has_more']
	    end
		else
			current_user = nil
      reset_session
		end
	end

	def new

	end

	def initiateCharge
		if request.post?
			uuid = params[:initiateCharge][:customerID]
			curlCall = `curl -H "appName: #{ENV['appName']}" -H "nxtwxrthxxthToken: #{current_user.authentication_token}" -d "" -X GET #{SITEurl}/api/v1/users/#{uuid}`
				
	    response = Oj.load(curlCall)
	    
	    if response['success']
				redirect_to getinitiateCharge_path(customerUUID: uuid)
			else
				flash[:error] = response['message']
				redirect_to charges_path
			end
		end
	end


	def newInvoice
		paramsX = {
      "amount" => newInvoiceParams[:amount].to_s,
    }.to_json

    curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -H "nxtwxrthxxthToken: #{current_user.authentication_token}" -d '#{paramsX}' -X POST #{SITEurl}/api/v2/stripe-charges`

		response = Oj.load(curlCall)

    if response['success']
			flash[:success] = "Deposit Made"
      redirect_to charges_path
    else
			flash[:error] = response['message']
      redirect_to request.referrer
    end
	end


	def payNow
		if current_user&.authentication_token
			curlCall = current_user&.indexStripeChargesAPI(params)

			response = Oj.load(curlCall)
			
	    if response['success']
				@pending = response['pending']
	    else
				flash[:error] = response['message']
	      redirect_to charges_path
	    end


		else
			current_user = nil
      reset_session
		end
	end

	private

	def newInvoiceParams
		paramsClean = params.require(:newInvoice).permit(:customer, :amount, :desc, :title)
	end

	def newChargeParams
		paramsClean = params.require(:newCharge).permit(:uuid, :quantity, :desc)
	end

	def stripeAmount(string)
    converted = (string.gsub(/[^0-9]/i, '').to_i)

    if string.include?(".")
      dollars = string.split(".")[0]
      cents = string.split(".")[1]

      if cents.length == 2
        stripe_amount = "#{dollars}#{cents}"
      else
        if cents === "0"
          stripe_amount = ("#{dollars}00")
        else
          stripe_amount = ("#{dollars}#{cents.to_i * 10}")
        end
      end

      return stripe_amount
    else
      stripe_amount = converted * 100
      return stripe_amount
    end
  end
end
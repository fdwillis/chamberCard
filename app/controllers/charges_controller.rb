class ChargesController < ApplicationController
	before_action :authenticate_user!

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

			curlCall = current_user&.indexStripeChargesAPI(params)
			response = Oj.load(curlCall)

		  if response['success']
			  	pullSource
				session[:payments] = response['deposits'] #edit stripe session meta for scheduling
				@payments = response['deposits'] #edit stripe session meta for scheduling
				@hasMore = response['has_more']
	    end
		else
			current_user = nil
      reset_session
		end
	end

	def new
		@title = params[:title]
		@uuid = params[:uuid]
		@desc = params[:desc]
	end

	def create
		timeSlot = newChargeParams[:uuid]
		quantity = newChargeParams[:quantity]
		desc = newChargeParams[:desc]
    
    curlCall = `curl -H "appName: #{ENV['appName']}" -H "nxtwxrthxxthToken: #{current_user.authentication_token}" -d "quantity=#{quantity}&timeSlot=#{timeSlot}&timeSlotCharge=true&description=#{desc}" #{SITEurl}/api/v2/stripe-charges`

		response = Oj.load(curlCall)
    
    if response['success']
			flash[:success] = "Purchase successful"
      redirect_to service_path(id: timeSlot)
    else
			flash[:error] = response['error']
      redirect_to service_path(id: timeSlot)
    end

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
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
		begin

			sleep 1
			if current_user&.authentication_token
				curlCall = current_user&.indexStripeChargesAPI(params)
				response = Oj.load(curlCall)
			  if response['success']
			  	pullSource
					@payments = response['selfCharges'] #edit stripe session meta for scheduling
					@available = response['available'] #edit stripe session meta for scheduling
					@depositTotal = response['selfChargeTotal'] #edit stripe session meta for scheduling
					@invested = response['invested'] #edit stripe session meta for scheduling
					@hasMore = response['has_more']
		    end
			else
				flash[:error] = "Something is wrong"
				redirect_to root_path
			end
		rescue Stripe::StripeError => e
			flash[:error] = "Something is wrong. \n #{e}"
			redirect_to root_path
		rescue Exception => e
			flash[:error] = "Something is wrong. \n #{e}"
			redirect_to root_path
		end
		end

	def new
		@paymentLinks = [
			{
				monthlyAmount: 5,
				stripePriceID: ENV['stripePriceID5']
			},{
				monthlyAmount: 10,
				stripePriceID: ENV['stripePriceID10']
			},{
				monthlyAmount: 500000,
				stripePriceID: ENV['stripePriceID500000']
			},
		]
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
		case true
		when params['newInvoice'].present?
			paramsX = {
	      "amount" => newInvoiceParams[:amount].to_s,
	    }.to_json

	    curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -H "nxtwxrthxxthToken: #{current_user.authentication_token}" -d '#{paramsX}' -X POST #{SITEurl}/api/v2/stripe-charges`
		when params['newSubscription'].present?
			debugger
			
		end

		# if newInvoiceParams
	  # end

		# if newSubscriptionParams
	  # end

		response = Oj.load(curlCall)
		sleep 3
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
		paramsClean = params.require(:newInvoice).permit(:amount, :quantity)
	end

	def newSubscriptionParams
		paramsClean = params.require(:newSubscription).permit(:price,:quantity)
	end

	def newChargeParams
		paramsClean = params.require(:newCharge).permit(:uuid, :quantity, :desc)
	end
end
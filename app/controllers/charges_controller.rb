class ChargesController < ApplicationController
	before_action :authenticate_user!

	def payments
		grabCart
		if current_user&.authentication_token

			curlCall = current_user&.indexStripeChargesAPI(params)
		  response = Oj.load(curlCall)
		  
			@customerPayments = response['charges'] #edit stripe session meta for scheduling

		  if response['success']
				@hasMore = response['has_more']
	    end
		else
			current_user = nil
      reset_session
		end
	end
	
	def index
		grabCart
		if current_user&.authentication_token

			curlCall = current_user&.indexStripeChargesAPI(params)
		  response = Oj.load(curlCall)

		  if response['success']
				session[:payments] = response['charges'] #edit stripe session meta for scheduling
				@payments = response['charges'] #edit stripe session meta for scheduling
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
    
    curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "quantity=#{quantity}&timeSlot=#{timeSlot}&timeSlotCharge=true&description=#{desc}" #{SITEurl}/api/v1/charges`

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
			curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "" -X GET #{SITEurl}/api/v1/users/#{uuid}`
				
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
		customer = newInvoiceParams[:customer]
		desc = newInvoiceParams[:desc]
		title = newInvoiceParams[:title]

    subtotal = stripeAmount(newInvoiceParams[:amount])
		application_fee_amount = (subtotal * (ENV['serviceFee'].to_i * 0.01)).to_i
		stripeFee = (((subtotal+application_fee_amount) * 0.03) + 29).to_i

		amount = subtotal + application_fee_amount + stripeFee

    curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "application_fee_amount=#{application_fee_amount}&customer=#{customer}&description=#{title}&amount=#{amount}" -X POST #{SITEurl}/api/v2/charges`

		response = Oj.load(curlCall)

    if response['success']
			flash[:success] = "Invoice Created"
      redirect_to stripe_customers_path(params[:id])
    else
			flash[:error] = response['message']
      redirect_to request.referrer
    end
	end

	def acceptInvoice
		charge = params[:stripeChargeID]
		
    curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X PATCH #{SITEurl}/api/v1/charges/#{charge}`

		response = Oj.load(curlCall)
    if response['success']
			flash[:notice] = "Invoice Paid"
			
      redirect_to charges_path
    else
			flash[:error] = response['message']
      redirect_to charges_path
    end
		
	end

	def payNow
		grabCart
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

	def customerPay
		if current_user&.authentication_token
			begin
				paidInvoice = Stripe::Invoice.pay(params['authPay']['invoiceToPay'], {}, {stripe_account: params['authPay']['sellerToChargeAs']})
				
				if paidInvoice['status'] == 'paid'
					flash[:success] = "Invoice Paid"
		      redirect_to charges_path
				else
					flash[:alert] = "Invoice Not Paid"
		      redirect_to charges_path
				end
			rescue Stripe::StripeError => e
				flash[:alert] = e.error.message
	      redirect_to charges_path
				
			rescue Exception => e
				flash[:alert] = e
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
end
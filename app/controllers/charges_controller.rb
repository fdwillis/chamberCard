class ChargesController < ApplicationController
	before_action :authenticate_user!
	
	def index
		if current_user&.authentication_token

			if !session[:customerCharges].blank?
				@invoices = session[:invoices]
				@pending = session[:pending]
				@anonCharges = session[:charges] #edit stripe session meta for scheduling
				@customerCharges = session[:customerCharges] #edit lineItems meta for scheduling
			else
				chargesNcustomers
				@pending = session[:pending]
				@invoices = session[:invoices]
				@anonCharges = session[:charges] #edit stripe session meta for scheduling
				@customerCharges = session[:customerCharges] #edit lineItems meta for scheduling
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
    
    curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "quantity=#{quantity}&timeSlot=#{timeSlot}&timeSlotCharge=true&description=#{desc}" #{SITEurl}/v1/charges`

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
			curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "" -X GET #{SITEurl}/v1/users/#{uuid}`
				
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
		amount = newInvoiceParams[:amount]
		desc = newInvoiceParams[:desc]
		title = newInvoiceParams[:title]
    
    curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "customer=#{customer}&title=#{title}&desc=#{desc}&managerInvoice=true&amount=#{amount}" -X POST #{SITEurl}/v1/charges`

		response = Oj.load(curlCall)

    if response['success']
			chargesNcustomers
			flash[:success] = "Invoice Created"
      redirect_to charges_path
    else
			flash[:error] = response['message']
      redirect_to charges_path
    end
	end

	def acceptInvoice
		charge = params[:stripeChargeID]
		
    curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X PATCH #{SITEurl}/v1/charges/#{charge}`

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
		if current_user&.authentication_token
			chargesNcustomers
			@invoices = session[:invoices]
			@pending = session[:pending]
			@anonCharges = session[:charges] #edit stripe session meta for scheduling
			@customerCharges = session[:customerCharges] #edit lineItems meta for scheduling
		else
			current_user = nil
      reset_session
		end
	end

	def customerPay
		if current_user&.authentication_token
			begin
				
				# finalizeInvoice = Stripe::Invoice.finalize_invoice(params['customerPayInvoice']['invoiceToPay'],{},{stripe_account: params['customerPayInvoice']['sellerToChargeAs']})
				paidInvoice = Stripe::Invoice.pay(params['customerPayInvoice']['invoiceToPay'], {}, {stripe_account: params['customerPayInvoice']['sellerToChargeAs']})

				chargesNcustomers
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
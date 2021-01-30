class ChargesController < ApplicationController
	before_action :authenticate_user!
	
	def index
		if current_user&.authentication_token
			curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "" -X GET #{SITEurl}/v1/charges`
			
	    response = Oj.load(curlCall)
				
	    if !response.blank? && response['success']
				@payments = response['payments']
				@overdue = response['overdue']
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

	def new
		@title = params[:title]
		@uuid = params[:uuid]
		@desc = params[:desc]
	end

	def create
		timeSlot = params[:newCharge][:uuid]
		quantity = params[:newCharge][:quantity]
		desc = params[:newCharge][:desc]
    
    curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "quantity=#{quantity}&timeSlot=#{timeSlot}&timeSlotCharge=true&description=#{desc}" #{SITEurl}/v1/charges`

		response = Oj.load(curlCall)
    
    if !response.blank? && response['success']
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
			curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "" -X GET #{SITEurl}/v1/users/#{uuid}`
				
	    response = Oj.load(curlCall)
	    
	    if !response.blank? && response['success']
				redirect_to getinitiateCharge_path(customerUUID: uuid)
			else
				flash[:error] = response['message']
				redirect_to charges_path
			end
		end
	end

	def trackingNumber
		if request.post?
			invoice = params[:trackingNumber][:invoice]
			
			if !params[:trackingNumber][:trackingIDs].blank?
				trackingIDs = params[:trackingNumber][:trackingIDs]

				curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}"  -d 'invoice=#{invoice}&trackingIDs=#{trackingIDs}' -X POST #{SITEurl}/v1/tracking`
			elsif !params[:trackingNumber][:orderIssueStatus].blank?
				orderIssueStatus = ActiveModel::Type::Boolean.new.cast(params[:trackingNumber][:orderIssueStatus])
				merchantStripeID = params[:trackingNumber][:merchantStripeID]
				curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}"  -d 'invoice=#{invoice}&orderIssueStatus=#{orderIssueStatus}&merchantStripeID=#{merchantStripeID}' -X POST #{SITEurl}/v1/tracking`
			else
				flash[:error] = "Something was missing"
				redirect_to request.referrer
				return
			end

	    response = Oj.load(curlCall)

	    if !response.blank? && response['success']
				flash[:success] = response['message']
				redirect_to request.referrer
			else
				flash[:error] = "Something went wrong"
				redirect_to request.referrer
			end
		end
	end

	def requestBooking
		if request.post?
			serviceToBook = params[:requestBooking][:serviceToBook]

			year = params[:requestBooking]["dateRequested(1i)"]
			month = params[:requestBooking]["dateRequested(2i)"]
			day = params[:requestBooking]["dateRequested(3i)"]

			hour = params[:requestBooking]["my_time(4i)"]
			minute = params[:requestBooking]["my_time(5i)"]

			buildDate = "#{year}/#{month}/#{day} #{hour}:#{minute}"
			if !year.blank? && !month.blank? && !day.blank?
				dateRequested = params[:requestBooking][:dateRequested]
				merchantStripeID = params[:requestBooking][:merchantStripeID]
				
				curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}"  -d 'serviceToBook=#{serviceToBook}&dateRequested=#{buildDate}&merchantStripeID=#{merchantStripeID}' -X POST #{SITEurl}/v1/booking-request`
			else
				flash[:error] = "Something was missing"
				redirect_to request.referrer
				return
			end

	    response = Oj.load(curlCall)

	    if !response.blank? && response['success']
				flash[:success] = "Request Submitted"
				redirect_to request.referrer
			else
				flash[:error] = "Something went wrong"
				redirect_to request.referrer
			end
		end
	end


	def newInvoice
		customer = params[:newInvoice][:customer]
		amount = params[:newInvoice][:amount]
		desc = params[:newInvoice][:desc]
		title = params[:newInvoice][:title]
    
    curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "customer=#{customer}&title=#{title}&desc=#{desc}&managerInvoice=true&amount=#{amount}" -X POST #{SITEurl}/v1/stripe-charges`

		response = Oj.load(curlCall)

    if !response.blank? && response['success']
			
			flash[:success] = "Invoice Created"
      redirect_to charges_path
    else
			flash[:error] = response['message']
      redirect_to charges_path
    end
	end

	def acceptInvoice
		charge = params[:stripeChargeID]
		
    curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X PATCH #{SITEurl}/v1/stripe-charges/#{charge}`

		response = Oj.load(curlCall)

    if !response.blank? && response['success']
			flash[:notice] = "Invoice Paid"
			
      redirect_to charges_path
    else
			flash[:error] = response['message']
      redirect_to charges_path
    end
		
	end

	def acceptBooking
		# for manager to accept proposed time by client without change
		serviceToAccept = params[:acceptBooking][:serviceToAccept]
		
    curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -X PATCH #{SITEurl}/v1/booking-request/#{serviceToAccept}`

		response = Oj.load(curlCall)

    if !response.blank? && response['success']
			flash[:success] = "Booking Scheduled"
			
      redirect_to request.referrer
    else
			flash[:error] = response['message']
      redirect_to request.referrer
    end
		
	end
end
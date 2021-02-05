class ScheduleController < ApplicationController
	before_action :authenticate_user!, except: :timeKitCancel

	protect_from_forgery with: :null_session, only: :timeKitCancel
	
	def index
		if current_user&.authentication_token
			curlCall = Charge.APIindex(current_user)
			
	    response = Oj.load(curlCall)
				
	    if response['success']
				@payments = response['payments']
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

	# webhook
	def timeKitCancel
		#  place in webhook controller
		metaData = params['meta']
		timeKitID = params['id']
		connectAccount = metaData['connectAccount']
		invoiceItem = metaData['invoiceItem']


		stripeInvoiceItem = Stripe::InvoiceItem.retrieve(invoiceItem, {stripe_account: connectAccount})
		stripeMetaData = stripeInvoiceItem['metadata']
		claimedInt = stripeMetaData['claimed'].to_i

		ogTimekitString = stripeMetaData['timeKitBookingID']
		ogTimekitArray = ogTimekitString.split(",")
		
		# edit metadata by removing timekitID of meeting passed
		if ogTimekitArray.include?(timeKitID)
			ogTimekitArray.delete(timeKitID)
			
			invoiceUpdated = Stripe::InvoiceItem.update(
			  stripeInvoiceItem['id'],
			  {
			  	metadata: {

						timeKitBookingID: ogTimekitArray.join(","),
						claimed: "#{claimedInt -= 1}"
					}
				}, {stripe_account: connectAccount}
			)
		end

		render json: {
			success: true
		}
		return
	end


	def acceptBooking
		# sync booking to manager calendar
		bookingDone = current_user&.syncTimekit(params[:acceptBooking])

		if bookingDone[:success]

			curlCall = Schedule.APIaccept(current_user, params[:acceptBooking], bookingDone[:timeKitBookingID])

			response = Oj.load(curlCall)

	    if response['success']
				flash[:success] = "Booking Scheduled"
				
	      redirect_to request.referrer
	    else
				flash[:error] = response['message']
	      redirect_to request.referrer
	    end
		else
			flash[:error] = "Please don't double book: #{bookingDone[:message]}"
      redirect_to request.referrer
		end
	end

	def requestBooking
		if request.post?

			Schedule.APIrequest(current_user, params[:requestBooking])

			

	    response = Oj.load(curlCall)

	    if response['success']
				flash[:success] = "Request Submitted"
				redirect_to request.referrer
			else
				flash[:error] = "Something went wrong"
				redirect_to request.referrer
			end
		end
	end
end
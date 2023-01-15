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
			pullSource
			if current_user&.authentication_token
				curlCall = current_user&.indexStripeChargesAPI(params)
				response = Oj.load(curlCall)
			  if response['success']
			  	@reinvestments = response['reinvestments']
					@payments = response['selfCharges'] + @reinvestments
					@available = response['available'] #edit stripe session meta for scheduling
					@subscriptionTotal = response['subscriptionTotal'] 
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
				monthlyAmount: 50,
				stripePriceID: ENV['stripePriceID50']
			},{
				monthlyAmount: 250,
				stripePriceID: ENV['stripePriceID250']
			},{
				monthlyAmount: 1000,
				stripePriceID: ENV['stripePriceID1000']
			}
		]
	end

	def create
		begin	
			if params[:charges][:reinvestment].to_sym == :true
				cardHolderID = Stripe::Customer.retrieve(current_user&.stripeCustomerID)['metadata']['cardHolder']
				amountToReinvest = (params[:charges][:amount].to_f * 100).to_i


				cardholder = Stripe::Issuing::Cardholder.retrieve(cardHolderID)
	      loadSpendingMeta = cardholder['spending_controls']['spending_limits']
	      someCalAmount = loadSpendingMeta&.first['amount'].to_i - amountToReinvest
				
				payout = Stripe::Payout.create({
				  amount: amountToReinvest,
				  currency: 'usd',
				  source_type:'issuing',
				  metadata: {reinvestment: true, stripeCustomerID: current_user&.stripeCustomerID, cardHolder: cardHolderID, payout: false }
				})
	      updateAmount = Stripe::Issuing::Cardholder.update(cardHolderID,{spending_controls: {spending_limits: [amount: someCalAmount, interval: 'per_authorization']}})

				if payout['id'].present?
					flash[:success] = "Your Reinvestment Was Successful"
					redirect_to charges_path
				end
			else
				flash[:error] = "Something Went Wrong"
				redirect_to charges_path
			end
		rescue Stripe::StripeError => e
			render json: {
				error: e,
				success: false
			}
		rescue Exception => e
			render json: {
				message: e
			}
		end	
	end

	def show
		@available = Stripe::Issuing::Cardholder.retrieve(Stripe::Customer.retrieve(current_user&.stripeCustomerID)['metadata']['cardHolder'])['spending_controls']['spending_limits'][0]['amount']
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

    if response['success']
			flash[:success] = "Deposit Made"
      redirect_to charges_path
    else
			flash[:error] = response['message']
      redirect_to request.referrer
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
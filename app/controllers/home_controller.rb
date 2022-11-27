class HomeController < ApplicationController
	before_action :authenticate_user!, except: [:welcome, :membership, :profile]

	def plaid
    require 'plaid'
		

    configuration = Plaid::Configuration.new
    configuration.server_index = Plaid::Configuration::Environment["sandbox"]
    configuration.api_key["PLAID-CLIENT-ID"] = ENV['plaidClient']
    configuration.api_key["PLAID-SECRET"] = ENV['plaidSecret']

    api_client = Plaid::ApiClient.new(configuration)

    @plaidClient = Plaid::PlaidApi.new(api_client)

    # Create the link_token with all of your configurations
    link_token_create_request = Plaid::LinkTokenCreateRequest.new({
      :user => { :client_user_id => current_user.uuid.to_s },
      :client_name => 'Netwerth',
      :products => %w[investments],
      # :products => %w[assets auth identity investments liabilities transactions],
      :country_codes => ['US'],
      :language => 'en',
      redirect_uri: 'http://localhost:3001/plaid'
    })

    @linkToken = @plaidClient.link_token_create(link_token_create_request).link_token
    session[:link_token] = @linkToken
		
	end

	def my_card
		pullCustomer = Stripe::Customer.retrieve(current_user&.stripeCustomerID)
		@cardDetails = Stripe::Issuing::Card.retrieve(pullCustomer['metadata']['issuedCard'])
	end

	def profile
		if current_user&.authentication_token
			if !current_user&.stripeCustomerID.blank?
				callCurl = current_user&.showStripeCustomerAPI(current_user&.stripeCustomerID)
				if callCurl['success']
					@cards = callCurl['cards']
					@bankAccounts = callCurl['bankAccounts']
					@sources = @cards + @bankAccounts
					@phone = callCurl['stripeCustomer']['phone']
					@name = callCurl['stripeCustomer']['name']
					@email = current_user&.email
				else
					flash[:error] = callCurl['message']
				end
			end
		end
	end

	def membership
		# if current member show membership with discount saving
		# when creating plans add lookup_keys to be able to divide by monthly/annual


		loadBasic = ENV["basicMonthlyMembership"].split(",")
		loadSaver = ENV["saverMonthlyMembership"].split(",")
		loadElite = ENV["eliteMonthlyMembership"].split(",")

		basicMonthly = ab_test(:basicMonthlyMembership, {loadBasic[0] => 0.75} , {loadBasic[1]=> 8}, {loadBasic[2]=> 1.25})
		saverMonthly = ab_test(:saverMonthlyMembership, {loadSaver[0] => 0.75} , {loadSaver[1] => 8}, {loadSaver[2] => 1.25})
		eliteMonthly = ab_test(:eliteMonthlyMembership, {loadElite[0] => 0.75} , {loadElite[1] => 8}, {loadElite[2] => 1.25})
	
		@basicMonthlyMembership = Stripe::Price.retrieve("price_#{basicMonthly}")
		@saverMonthlyMembership = Stripe::Price.retrieve("price_#{saverMonthly}")
		@eliteMonthlyMembership = Stripe::Price.retrieve("price_#{eliteMonthly}")

		if current_user&.member?
			@subsc = Stripe::Subscription.list({customer: current_user&.stripeCustomerID})['data'][0]
			@price = Stripe::Price.retrieve(!@subsc.blank? ? @subsc['items']['data'][0]['price']['id'] : nil)
		end

		
	end

	def join
		if current_user&.paymentOn?
			params = {price: joinParams[:plan], serviceFee: joinParams[:serviceFee]}.to_json
			
			curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -H "nxtwxrthxxthToken: #{current_user&.authentication_token}" -d '#{params}' -X POST #{SITEurl}/api/v1/subscriptions`
			
			response = Oj.load(curlCall)

			if response['success']
				flash[:success] = "You are now a member! Enjoy the savings!"
	      redirect_to membership_path
	    else
				flash[:error] = response['error']
	      redirect_to membership_path
	    end
	  else
			flash[:alert] = "Click 'Proceed' below to start setting up membership"
      redirect_to profile_path
    end
	end

	def cancelSub

    curlCall = `curl -H "nxtwxrthxxthToken: #{current_user&.authentication_token}" -X DELETE #{SITEurl}/api/v1/subscriptions/#{params[:cancel][:subscription]}?serviceFee=#{ENV['serviceFee']}`

		response = Oj.load(curlCall)

    if response['success']
    	
			flash[:success] = response['message']
			
      redirect_to membership_path
    else
			flash[:error] = response['message']
      redirect_to membership_path
    end

	end

	def welcome
		render :layout => "landing1"
	end

	def verifyPhone
		if request.get?
		end

		if request.post?
			curlCall = `curl -H "Content-Type: application/json" -H "appName: #{ENV['appName']}" -H "nxtwxrthxxthToken: #{current_user&.authentication_token}" -d '#{params[:verifyPhone].to_json}' -X PATCH #{SITEurl}/api/v1/verify`

			response = Oj.load(curlCall)

	    if response['success']
	    	current_user&.update(twilioPhoneVerify: response['twilioPhoneVerify'])

				flash[:success] = response['message']
				
	      redirect_to profile_path
	    else
				flash[:error] = response['message']
	      redirect_to verify_phone_path
	    end
		end
	end

	private

	def joinParams
		paramsClean = params.require(:join).permit(:serviceFee, :plan)
	end
end
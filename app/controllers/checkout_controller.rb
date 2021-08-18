class CheckoutController < ApplicationController

	def create
		grabCart

		if current_user&.authentication_token

			customerFetch = current_user&.showStripeCustomerAPI(current_user&.stripeCustomerID)['stripeCustomer']['id']

			checkoutRequest = stripeCheckoutRequest(session[:lineItems], customerFetch)	

			if checkoutRequest['success']
			  paidInvoice = Stripe::Invoice.pay(checkoutRequest['invoice'], {}, {stripe_account: ENV['connectAccount']})
		
				if paidInvoice['status'] == 'paid'
					
					curlCall = `curl -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -H "appName: #{ENV['appName']}" -X DELETE #{SITEurl}/api/v1/carts/#{ENV['connectAccount']}`

					response = Oj.load(curlCall)
				    
			    if response['success']
						session[:cart_id] = nil
						session[:coupon] = nil
			    	session[:percentOff] = nil
						redirect_to request.referrer
						flash[:success] = "Purchase Complete"
			    else
			    	flash[:error] = response['error']
			    	redirect_to carts_path
			    end
				else
					flash[:alert] = "Something went wrong"
		      redirect_to carts_path
				end

			elsif checkoutRequest['error']
				redirect_to request.referrer
				flash[:error] = checkoutRequest['error']
			else
				redirect_to request.referrer
				flash[:notice] = "Smethings wrng"
			end
	  else
	  	begin
			  if !session[:lineItems].blank?

				  token = stripeTokenRequest(attachSourceParams, ENV['connectAccount'])
				  
				  if token['success']
					  connectAccountCus = stripeCustomerRequest(token['token'])

					  checkoutRequest = stripeCheckoutRequest(session[:lineItems], connectAccountCus['id'])	
					  #collect invoice payment
					  if checkoutRequest['success']
						  paidInvoice = Stripe::Invoice.pay(checkoutRequest['invoice'], {}, {stripe_account: ENV['connectAccount']})
					
							if paidInvoice['status'] == 'paid'
								curlCall = `curl -H "appName: #{ENV['appName']}" -X DELETE #{SITEurl}/api/v1/carts/#{@cartID}`

								response = Oj.load(curlCall)
							    
						    if response['success']
									session[:cart_id] = nil
									session[:coupon] = nil
						    	session[:percentOff] = nil
									redirect_to request.referrer
									flash[:success] = "Purchase Complete"
						    else
						    	flash[:error] = response['error']
						    	redirect_to carts_path
						    end
							else
								flash[:alert] = "Something went wrong"
					      redirect_to carts_path
							end

						elsif checkoutRequest['error']
							redirect_to request.referrer
							flash[:error] = checkoutRequest['error']
						else
							redirect_to request.referrer
							flash[:notice] = "Smethings wrng"
						end
				  else
						redirect_to request.referrer
						flash[:error] = token['error']
				  end
					return
				else
					flash[:alert] = 'Add items to your cart'
					redirect_to carts_path
				end
			rescue Stripe::StripeError => e
				flash[:error] = e.error.message
				redirect_to carts_path
				return
			rescue Exception => e
				flash[:error] = e
				redirect_to carts_path
				return
			end
	  end
		
	end

	
	def cancel
	end

	def thankYou
		begin
			# in_1JORINQXl4puf0Hk9tA1ESXV
			stripeInvoiceIDRender = "in_#{params[:id]}"
			@stripeInvoiceInfo = Stripe::Invoice.retrieve(stripeInvoiceIDRender, {stripe_account: ENV['connectAccount']})
		rescue Stripe::StripeError => e
			flash[:error] = e.error.message
			redirect_to carts_path
		end
	end

	private

	def attachSourceParams
		paramsClean = params.require(:checkout).permit(:number, :exp_year, :exp_month, :cvc)
		return paramsClean.reject{|_, v| v.blank?}
	end
end
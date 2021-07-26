class InvoicesController < ApplicationController
	before_action :authenticate_user!

	def create
		customer = newInvoiceParams[:customer]
		desc = newInvoiceParams[:desc]
		title = newInvoiceParams[:title]

    subtotal = stripeAmount(newInvoiceParams[:amount])
		application_fee_amount = (subtotal * (ENV['serviceFee'].to_i * 0.01)).to_i
		stripeFee = (((subtotal+application_fee_amount) * 0.03) + 30).to_i

		paramsX = {
			"customer" => customer,
			"description" => "Additional Invoice | #{title}",
			"amount" => subtotal + application_fee_amount + stripeFee,
			"application_fee_amount" => application_fee_amount
		}

    curlCall = `curl -H "appName: #{ENV['appName']}" -H "bxxkxmxppAuthtoken: #{current_user.authentication_token}" -d "description=Additional Invoice | #{title}&customer=#{customer}&amount=#{subtotal + application_fee_amount + stripeFee}&application_fee_amount=#{application_fee_amount}" -X POST #{SITEurl}/api/v2/invoices`

		response = Oj.load(curlCall)

    if response['success']
			flash[:success] = "Invoice Created"
      redirect_to pay_now_path
    else
			flash[:error] = response['message']
      redirect_to request.referrer
    end
	end

	
	private

	def newInvoiceParams
		paramsClean = params.require(:checko).permit(:customer, :amount, :desc, :title)
	end

	def newChargeParams
		paramsClean = params.require(:newCharge).permit(:uuid, :quantity, :desc)
	end
end
class InvoicesController < ApplicationController
	before_action :authenticate_user!

	
	private

	def newInvoiceParams
		paramsClean = params.require(:checko).permit(:customer, :amount, :desc, :title)
	end

	def newChargeParams
		paramsClean = params.require(:newCharge).permit(:uuid, :quantity, :desc)
	end
end
class Charge < ApplicationRecord

	def self.paymentIntentNet(paymentIntent)
		bt = Stripe::PaymentIntent.retrieve(paymentIntent)['charges']['data'][0]['balance_transaction']
		balanceTransaction = Stripe::BalanceTransaction.retrieve(bt)
		{net: balanceTransaction['net'], fee: balanceTransaction['fee'], amount: balanceTransaction['amount']}
	end
	
end
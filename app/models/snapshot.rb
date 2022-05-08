class Snapshot < ApplicationRecord
	has_many :recordings

	def getCash
		if recordings.count > 0 
			cashToRecordWith = (recordings.last.cash - self.cash)
			return {cash: recordings.last.cash, diff: (cashToRecordWith/self.cash).round(2) * 100}
		else
			self.cash
		end
	end

	def getEquities
		if recordings.count > 0 
			equitiesToRecordWith = (recordings.last.equities - self.equities)
			return {equities: recordings.last.equities, diff: (equitiesToRecordWith/self.equities).round(2) * 100}
		else
			self.equities
		end
	end

	def getExpenses
		if recordings.count > 0 
			expensesToRecordWith = (recordings.last.expenses - self.expenses)
			return {expenses: recordings.last.expenses, diff: (expensesToRecordWith/self.expenses).round(2) * 100}
		else
			self.expenses
		end
	end
	
	def getIncome
		if recordings.count > 0 
			incomeToRecordWith = (recordings.last.income - self.income)
			return {income: recordings.last.income, diff: (incomeToRecordWith/self.income).round(2) * 100}
		else
			self.income
		end
	end

	def getLiabilities
		if recordings.count > 0 
			liabilitiesToRecordWith = (recordings.last.liabilities - self.liabilities)
			return {liabilities: recordings.last.liabilities, diff: (liabilitiesToRecordWith/self.liabilities).round(2) * 100}
		else
			self.liabilities
		end
	end
end

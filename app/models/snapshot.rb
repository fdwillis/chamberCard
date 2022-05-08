class Snapshot < ApplicationRecord
	has_many :recordings

	def getCash
		if recordings.count > 0 
			cashToRecordWith = (recordings.last.cash - self.cash)
			return {cash: recordings.last.cash, diff: (cashToRecordWith/self.cash).round(2) * 100}
		else
			return {cash: self.cash, diff: 0}
		end
	end

	def getEquities
		if recordings.count > 0 
			equitiesToRecordWith = (recordings.last.equities - self.equities)
			return {equities: recordings.last.equities, diff: (equitiesToRecordWith/self.equities).round(2) * 100}
		else
			return {equities: self.equities, diff: 0}
		end
	end

	def getExpenses
		if recordings.count > 0 
			expensesToRecordWith = (recordings.last.expenses - self.expenses)
			return {expenses: recordings.last.expenses, diff: (expensesToRecordWith/self.expenses).round(2) * 100}
		else
			return {expenses: self.expenses, diff: 0}
		end
	end
	
	def getIncome
		if recordings.count > 0 
			incomeToRecordWith = (recordings.last.income - self.income)
			return {income: recordings.last.income, diff: (incomeToRecordWith/self.income).round(2) * 100}
		else
			return {income: self.income, diff: 0}
		end
	end

	def getLiabilities
		if recordings.count > 0 
			liabilitiesToRecordWith = (recordings.last.liabilities - self.liabilities)
			return {liabilities: recordings.last.liabilities, diff: (liabilitiesToRecordWith/self.liabilities).round(2) * 100}
		else
			return {liabilities: self.liabilities, diff: 0}
		end
	end
end

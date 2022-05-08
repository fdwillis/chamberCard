class Recording < ApplicationRecord
  belongs_to :snapshot

  def getCash
    if cash > 0 
      cashToRecordWith = (cash - self.snapshot.cash)
      return {cash: cash, diff: (cashToRecordWith/self.snapshot.cash).round(2) * 100}
    else
      return {cash: self.snapshot.cash, diff: 0}
    end
  end

  def getEquities
    if equities > 0 
      equitiesToRecordWith = (equities - self.snapshot.equities)
      return {equities: equities, diff: (equitiesToRecordWith/self.snapshot.equities).round(2) * 100}
    else
      return {equities: self.snapshot.equities, diff: 0}
    end
  end

  def getExpenses
    if expenses > 0 
      expensesToRecordWith = (expenses - self.snapshot.expenses)
      return {expenses: expenses, diff: (expensesToRecordWith/self.snapshot.expenses).round(2) * 100}
    else
      return {expenses: self.snapshot.expenses, diff: 0}
    end
  end
  
  def getIncome
    if income > 0 
      incomeToRecordWith = (income - self.snapshot.income)
      return {income: income, diff: (incomeToRecordWith/self.snapshot.income).round(2) * 100}
    else
      return {income: self.snapshot.income, diff: 0}
    end
  end

  def getLiabilities
    if liabilities > 0 
      liabilitiesToRecordWith = (liabilities - self.snapshot.liabilities)
      return {liabilities: liabilities, diff: (liabilitiesToRecordWith/self.snapshot.liabilities).round(2) * 100}
    else
      return {liabilities: self.snapshot.liabilities, diff: 0}
    end
  end
end

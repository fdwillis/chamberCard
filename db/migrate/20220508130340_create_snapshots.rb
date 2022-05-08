class CreateSnapshots < ActiveRecord::Migration[6.0]
  def change
    create_table :snapshots do |t|
      t.integer :year
      t.integer :month
      t.float :cash
      t.float :equities
      t.float :expenses
      t.float :income
      t.float :liabilities

      t.timestamps
    end
  end
end

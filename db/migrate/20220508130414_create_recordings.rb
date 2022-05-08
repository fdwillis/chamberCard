class CreateRecordings < ActiveRecord::Migration[6.0]
  def change
    create_table :recordings do |t|
      t.integer :year
      t.integer :month
      t.float :cash
      t.float :equities
      t.float :expenses
      t.float :income
      t.float :liabilities
      t.belongs_to :snapshot, null: false, foreign_key: true

      t.timestamps
    end
  end
end

class CreateImages < ActiveRecord::Migration[6.0]
  def change
    create_table :images do |t|
      t.json :source
      t.belongs_to :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end

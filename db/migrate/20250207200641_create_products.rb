class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :description
      t.integer :price
      t.integer :discount_percentage
      t.references :company, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.references 
      t.timestamps
    end
  end
end

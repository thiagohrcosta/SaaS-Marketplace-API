class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :total_price
      t.boolean :cart_is_opened, null: false, default: true
      t.timestamps
    end
  end
end

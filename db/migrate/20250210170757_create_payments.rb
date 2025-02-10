class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.integer :total_price
      t.string :stripe_client_id
      t.jsonb :stripe_data
      t.timestamps
    end
  end
end

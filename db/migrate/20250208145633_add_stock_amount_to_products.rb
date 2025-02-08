class AddStockAmountToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :stock_amount, :integer, default: 1
  end
end

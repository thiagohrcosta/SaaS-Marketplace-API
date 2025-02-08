class AddIsAvailableToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :is_available, :boolean, default: true
  end
end

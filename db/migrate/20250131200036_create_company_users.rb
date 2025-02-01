class CreateCompanyUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :company_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      
      t.timestamps
    end
  end
end

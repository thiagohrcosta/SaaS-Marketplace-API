class Company < ApplicationRecord
  has_many :company_users, dependent: :destroy
  has_many :products, dependent: :destroy

  has_one_attached :logo

  validates :name, presence: true
end

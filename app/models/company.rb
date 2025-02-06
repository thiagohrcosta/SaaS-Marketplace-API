class Company < ApplicationRecord
  has_many :company_users, dependent: :destroy

  validates :name, presence: true
end

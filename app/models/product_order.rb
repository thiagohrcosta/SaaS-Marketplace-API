class ProductOrder < ApplicationRecord
  belongs_to :order
  belongs_to :product
  belongs_to :user
end

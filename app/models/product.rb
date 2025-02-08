class Product < ApplicationRecord
  belongs_to :company
  belongs_to :category
  has_many_attached :photos
end

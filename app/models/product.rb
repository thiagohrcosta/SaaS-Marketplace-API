class Product < ApplicationRecord
  belongs_to :company
  has_many_attached :photos
end

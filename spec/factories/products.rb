FactoryBot.define do
  factory :product do
    name { "Book_#{rand(0...100000)}" }
    description { |product| "#{product.name} Book fake description" }
    price { rand(5000...10000) }
    discount_percentage { [0, 5].sample }
    stock_amount { 1 }
    is_available { true }

    association :company
    association :category
  end
end

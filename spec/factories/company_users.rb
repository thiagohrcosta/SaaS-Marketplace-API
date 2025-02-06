FactoryBot.define do
  factory :company_user do
    company_id { rand(0..100) }
    user_id { rand(0..100) }
  end
end

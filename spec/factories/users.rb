FactoryBot.define do
  factory :user do
    full_name { Faker::Name.name }
    email { "email#{rand(0..99999)}@doe.com"}
    role { "user" || "company" }
    magic_link_token { SecureRandom.hex(32) }
  end
end

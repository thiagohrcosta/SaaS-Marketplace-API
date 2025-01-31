class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :trackable, :rememberable, :validatable

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: false, on: :create
  validates :encrypted_password, presence: false, on: :update

  enum role: {
    user: "user",
    company: "company",
    admin: "admin"
  }

  def password_required?
    false
  end
  
end

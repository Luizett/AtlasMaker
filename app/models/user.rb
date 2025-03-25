class User < ApplicationRecord
  has_secure_password
  has_one_attached :avatar, dependent: :destroy
  has_many :atlas, dependent: :destroy

  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 4 }
end

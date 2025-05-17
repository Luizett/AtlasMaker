class User < ApplicationRecord
  has_secure_password
  has_one_attached :avatar, dependent: :destroy
  has_many :atlases, dependent: :destroy

  validates :username,
            presence: true,
            uniqueness: true,
            length: { minimum: 3, maximum: 20 },
            format: {
              with: /\A[A-Za-z]*\z/,
              message: "must contain only latin letters"
            }

  validates :password, length: { minimum: 5, maximum: 20 }, unless: -> { password.blank? }

  validates :password_digest,
            presence: true
end

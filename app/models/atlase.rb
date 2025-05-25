class Atlase < ApplicationRecord
  belongs_to :user
  has_one_attached :atlas_img, dependent: :destroy
  has_many :sprites, dependent: :destroy

  validates :title,
            length: {minimum: 1, maximum: 40},
            presence: true,
            format: {
              with: /\A[A-Za-z0-9]*\z/
            }
end


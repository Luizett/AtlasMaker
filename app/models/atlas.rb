class Atlas < ApplicationRecord
  belongs_to :user
  has_one_attached :atlas_img, dependent: :destroy
  has_many :sprites, dependent: :destroy
end

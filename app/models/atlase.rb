class Atlase < ApplicationRecord
  belongs_to :user
  has_one_attached :atlas_img, dependent: :destroy
  # after_commit :atlas_img_analyze
  has_many :sprites, dependent: :destroy

  # private
  # def atlas_img_analyze
  #   atlas_img.analyze if atlas_img.attached?
  # end
end


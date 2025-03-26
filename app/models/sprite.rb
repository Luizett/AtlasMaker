class Sprite < ApplicationRecord
  belongs_to :atlas
  has_one_attached :sprite_img, dependent: :destroy
end

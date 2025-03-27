class Sprite < ApplicationRecord
  belongs_to :atlase
  has_one_attached :sprite_img, dependent: :destroy
end

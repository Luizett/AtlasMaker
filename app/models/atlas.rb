class Atlas < ApplicationRecord
  belongs_to :user
  has_one_attached :atlas, dependent: :destroy
  has_many :sprites, dependent: :destroy
end

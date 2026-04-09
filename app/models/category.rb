class Category < ApplicationRecord
  belongs_to :group
  has_many :items, dependent: :destroy
  has_many :purchase_histories, dependent: :destroy
  validates :name, presence: true
end

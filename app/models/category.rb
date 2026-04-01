class Category < ApplicationRecord
  belongs_to :group
  has_many :items
  validates :name, presence: true
end

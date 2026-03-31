class Item < ApplicationRecord
  belongs_to :group
  validates :name, presence: true
end
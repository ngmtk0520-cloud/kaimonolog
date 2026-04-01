class PurchaseHistory < ApplicationRecord
  belongs_to :item
  belongs_to :group
  validates :bought_at, presence: true
end

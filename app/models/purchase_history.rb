class PurchaseHistory < ApplicationRecord
  belongs_to :item
  belongs_to :group
  
  validates :bought_at, presence: true
  validates :price, numericality: { only_integer: true, allow_nil: true }

end

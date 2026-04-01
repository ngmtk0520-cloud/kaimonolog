class Item < ApplicationRecord
  belongs_to :group
  belongs_to :category, optional: true
  
  # 0: 都度(regular), 1: 定期(subscription), 2: スポット(spot)
  enum kind: { regular: 0, subscription: 1, spot: 2 }

  validates :name, presence: true
end
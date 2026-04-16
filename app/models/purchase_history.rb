class PurchaseHistory < ApplicationRecord
  belongs_to :item, optional: true
  belongs_to :group
  belongs_to :category, optional: true


  #購入したら紐ずくアイテムの平均サイクルを計算する
  after_create :update_item_average_cycle

  def start_time
    bought_at
  end

  validates :bought_at, presence: true
  validates :price, numericality: { only_integer: true, allow_nil: true }

  private

  def update_item_average_cycle
    # Itemモデルで作った計算メソッドを呼び出す
    item.update_average_cycle if item.present?
  end

end

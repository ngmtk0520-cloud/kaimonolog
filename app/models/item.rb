class Item < ApplicationRecord
  belongs_to :group
  belongs_to :category, optional: false
  has_many :purchase_histories, dependent: :nullify

  validates :name, presence: true
  validates :price, numericality: { only_integer: true, allow_nil: true }
  
  before_save :set_subscription_flag

  #平均購入サイクルを計算する
  def update_average_cycle
    # 履歴が2件未満なら何もしない
    return if purchase_histories.count < 2
    
    dates = purchase_histories.order(:bought_at).pluck(:bought_at).compact.map(&:to_date)
    
    # datesが空、または1件しかない場合の念のためのガード
    return if dates.size < 2

    intervals = dates.each_cons(2).map { |a, b| (b - a).to_i }

    # 平均を出して、cycle_days カラムを更新
    if intervals.any?
      avg = intervals.sum / intervals.size
      update(cycle_days: avg)
    end
  end

  def due_soon?
    # 定期購入のみ予測する,履歴が１件の場合は除外
    return false unless is_subscription? && cycle_days.to_i > 0
    last_purchase = purchase_histories.order(bought_at: :desc).first

    return false if last_purchase&.bought_at.nil?
    last_bought_at = last_purchase.bought_at.to_date
    
    # 次回の予定日 = 最後に買った日 + サイクル（日）
    # 次回の予定日「今日から4日以内」を判定
    expected_date = last_bought_at + cycle_days.days
    expected_date <= Date.today + 4.days
  end

  private

  def set_subscription_flag
    self.is_subscription = (category&.name == "定期購入")
  end
end
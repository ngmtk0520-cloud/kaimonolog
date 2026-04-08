class Item < ApplicationRecord
  enum :kind, { regular: 0, subscription: 1, spot: 2 }
  belongs_to :group
  belongs_to :category, optional: false
  has_many :purchase_histories, dependent: :nullify

  validates :name, presence: true
  validates :price, numericality: { only_integer: true, allow_nil: true }
  #平均購入サイクルを計算する
  def update_average_cycle
    return if purchase_histories.count < 2
    
    # 購入日を古い順に取得して、日付の間隔を計算する
    dates = purchase_histories.order(:bought_at).pluck(:bought_at).map(&:to_date)
    intervals = dates.each_cons(2).map { |a, b| (b - a).to_i}

    # 平均を出して、cycle_days カラムを更新
    avg = intervals.sum / intervals.size
    update(cycle_days: avg)
  end

  def due_soon?
    # 定期購入のみ予測する,履歴が１件の場合は除外
    return false unless subscription? && cycle_days.to_i > 0

    # 最後に買った日を取得
    last_bought_at = purchase_histories.order(bought_at: :desc).first.bought_at
    return false if last_bought_at.nil?
    
    # 次回の予定日 = 最後に買った日 + サイクル（日）
    # 次回の予定日「今日から4日以内」を判定
    expected_date = last_bought_at + cycle_days.days
    expected_date <= Date.today + 4.days
  end
end
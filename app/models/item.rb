class Item < ApplicationRecord
  belongs_to :group
  belongs_to :category, optional: false
  has_many :purchase_histories, dependent: :nullify
  # 0: 都度(regular), 1: 定期(subscription), 2: スポット(spot)
  enum kind: { regular: 0, subscription: 1, spot: 2 }

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
    # 購入履歴がない場合は判定できないので false
    return false if purchase_histories.empty? || cycle_days.nil?

    # 最後に買った日を取得
    last_bought_at = purchase_histories.order(bought_at: :desc).first.bought_at
    
    # 次回の予定日 = 最後に買った日 + サイクル（日）
    expected_date = last_bought_at + cycle_days.days
    
    # 予定日が「今日から7日以内」かつ「未来（または今日）」なら true
    # ※すでに切れているものも含める場合は expected_date <= Date.today + 7.days
    expected_date <= Date.today + 7.days
  end
end
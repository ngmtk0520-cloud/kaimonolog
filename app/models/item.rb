class Item < ApplicationRecord
  belongs_to :group
  belongs_to :category, optional: true
  has_many :purchase_histories, dependent: :destroy
  # 0: 都度(regular), 1: 定期(subscription), 2: スポット(spot)
  enum kind: { regular: 0, subscription: 1, spot: 2 }

  validates :name, presence: true

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
end
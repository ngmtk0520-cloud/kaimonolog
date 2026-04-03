class CalendarsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :set_beginning_of_week

  def index
    # アプリ内カレンダー用の「予定データ」を作成
    @calendar_events = []
    @group.items.subscription.where("cycle_days > 0").each do |item|
      # 最新購入日 ＋ 平均サイクル ＝ 次回予定日
      last_bought = item.purchase_histories.order(:bought_at).last&.bought_at || Time.current
      next_date = (last_bought + item.cycle_days.days).to_date
      # Simple Calendarに渡す形式（名称と開始日）
      @calendar_events << OpenStruct.new(name: "🛒 #{item.name}", start_time: next_date)
    end
  end

  private

  def set_group
    # ユーザーがグループに所属していない場合は、トップに戻して警告を出す
    @group = current_user.group
    redirect_to root_path, alert: "グループに参加してください" if @group.nil?
  end

  def set_beginning_of_week
    Date.beginning_of_week = :sunday
  end
end

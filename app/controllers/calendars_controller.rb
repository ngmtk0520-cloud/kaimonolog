class CalendarsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :set_beginning_of_week

  def index
    # アプリ内カレンダー用の「購入履歴」
    @calendar_events = PurchaseHistory.where(item_id: @group.items.pluck(:id))
    @calendar_events = @calendar_events.order(bought_at: :desc)
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

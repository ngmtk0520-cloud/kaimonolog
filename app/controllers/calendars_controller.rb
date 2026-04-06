class CalendarsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :set_beginning_of_week

  def index
    # アプリ内カレンダー用の「購入履歴」
    @calendar_events = PurchaseHistory.where(item_id: @group.items.pluck(:id))
    @calendar_events = @calendar_events.order(bought_at: :desc)
  end

  def show
    purchase_date = PurchaseHistory.where(item_id: @group.items.pluck(:id))
    @calendar_events = purchase_date.where(bought_at: params[:id].to_date.all_day)
    @total_price = @calendar_events.sum(:price)
    if @calendar_events.empty?
      redirect_to new_purchase_history_path(date: params[:id])
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

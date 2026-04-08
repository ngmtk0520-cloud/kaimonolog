class CalendarsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :set_beginning_of_week

  def index
    # アプリ内カレンダー用の「購入履歴」
      @calendar_events = PurchaseHistory.where(group_id: @group.id).order(bought_at: :desc)
  end

  def show
    @selected_date = params[:id].to_date
    # その日の履歴を、アイテム名も含めて効率よく取得（includes）
    @calendar_events = PurchaseHistory.where(group_id: @group.id)
                                      .where(bought_at: @selected_date.all_day)
                                      .includes(:item)
    
    @total_price = @calendar_events.sum(:price)

    # 履歴がない時だけ新規登録へ飛ばす
    if @calendar_events.empty?
      redirect_to new_purchase_history_path(date: @selected_date)
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

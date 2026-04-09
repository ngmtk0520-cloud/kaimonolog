class TotalExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group  
  def index
    @current_group ||= current_user.group  
    
    if @current_group
      # 1. すべての履歴（棒グラフ用）
      @all_histories = @current_group.purchase_histories
      
      # 2. 今月の履歴だけに絞り込む（円グラフ用）
      # Time.current.all_month => "2024-04-01 00:00:00" .. "2024-04-30 23:59:59"
      @this_month_histories = @all_histories.where(bought_at: Time.current.all_month)

      # 【円グラフ】今月のデータのみで集計
      @expense_chart_data = @this_month_histories.joins(:category)
                            .group("categories.name")
                            .sum("purchase_histories.price * purchase_histories.quantity")

      # 【棒グラフ】全期間のデータで推移を表示
      @monthly_chart_data = @all_histories.group_by_month(:bought_at).sum("purchase_histories.price * purchase_histories.quantity")
    else
      @expense_chart_data = {}
      @monthly_chart_data = {}
    end
  end
  private

    def set_group
      # ユーザーがグループに所属していない場合は、トップに戻して警告を出す
      @group = current_user.group
      redirect_to root_path, alert: "グループに参加してください" if @group.nil?
    end
end

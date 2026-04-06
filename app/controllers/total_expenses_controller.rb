class TotalExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group  
  def index
    @expense_chart_data = @group.purchase_histories.where(bought_at: Time.current.all_month).joins(item: :category).group("categories.name").sum(:price)
    puts "📊 グラフデータの中身: #{@expense_chart_data}"

    @monthly_chart_data = @group.purchase_histories.group_by_month(:bought_at).sum(:price)
  end

  private

    def set_group
      # ユーザーがグループに所属していない場合は、トップに戻して警告を出す
      @group = current_user.group
      redirect_to root_path, alert: "グループに参加してください" if @group.nil?
    end
end

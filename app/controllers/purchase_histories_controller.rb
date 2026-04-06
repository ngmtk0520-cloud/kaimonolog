class PurchaseHistoriesController < ApplicationController

  before_action :authenticate_user!
  before_action :set_group, only: [:edit, :update]
  before_action :set_purchase_history, only: [:edit, :update]


  def edit
  end

  def update
    if @purchase_history.update(purchase_history_params)
      redirect_to calendar_path(id: @purchase_history.bought_at.to_date), notice: "購入履歴が更新されました"
    else
      render :edit, alert: "購入履歴の更新に失敗しました"
    end
  end

  private

  def purchase_history_params
    params.require(:purchase_history).permit(:item_id, :bought_at, :price)
  end

  def set_purchase_history
    @purchase_history = PurchaseHistory.find(params[:id])
  end

  def set_group
    # ユーザーがグループに所属していない場合は、トップに戻して警告を出す
    @group = current_user.group
    redirect_to root_path, alert: "グループに参加してください" if @group.nil?
  end
end

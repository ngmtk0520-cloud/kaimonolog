class PurchaseHistoriesController < ApplicationController

  before_action :authenticate_user!
  before_action :set_group, only: [:new, :create, :edit, :update, :destroy,]
  before_action :set_purchase_history, only: [:edit, :update, :destroy, ]

  def edit
  end

  def update
    if @purchase_history.update(purchase_history_params)
      redirect_to calendar_path(id: @purchase_history.bought_at.to_date), notice: "購入履歴が更新されました"
    else
      render :edit, alert: "購入履歴の更新に失敗しました"
    end
  end

  def destroy
    @purchase_history.destroy
    redirect_to calendar_path(id: @purchase_history.bought_at.to_date), notice: "購入履歴が削除されました"
  end

  def new
    @purchase_history = PurchaseHistory.new(bought_at: params[:date])
    @categories = @group.categories
  end

  def create
    item = @group.items.find_or_create_by(name: params[:item_name], category_id: params[:category_id])
    @purchase_history = PurchaseHistory.new(purchase_history_params)
    @purchase_history.item_id = item.id
    @purchase_history.group_id = @group.id

    if @purchase_history.save
      redirect_to calendar_path(id: @purchase_history.bought_at.to_date), notice: "購入履歴が作成されました"
    else
      @categories = @group.categories
      render :new, alert: "購入履歴の作成に失敗しました"
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

  def item_params
    params.require(:item).permit(:name, :is_subscription, :is_checked, :category_id, :kind, :price)
  end
end

class PurchaseHistoriesController < ApplicationController

  before_action :authenticate_user!
  before_action :set_group, only: [:new, :create, :edit, :update, :destroy,]
  before_action :set_purchase_history, only: [:edit, :update, :destroy, ]

  def edit
    @current_group ||= @purchase_history.group 
    @categories = @current_group.categories 
    @items = @current_group.items 
  end

  def update
    if @purchase_history.update(purchase_history_params)
      redirect_to calendar_path(id: @purchase_history.bought_at.to_date), notice: "購入履歴が更新されました"
    else
      @current_group = @purchase_history.group
      @categories = @current_group.categories
      @items = @current_group.items
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
    # 1. 入力された名前とカテゴリーIDでアイテムを特定。なければ新しく作る。
    # ※@group.items 経由にすることで、他人のグループと混ざらないようにします。
    item = @group.items.find_or_create_by(
      name: params[:item_name],
      category_id: params[:category_id]
    )

    # 2. そのアイテムに紐づく「履歴」のインスタンスを作成
    @purchase_history = item.purchase_histories.build(purchase_history_params)
    @purchase_history.item_name = item.name
    
    # 3. 履歴側にもデータを補完（分析やカレンダー表示をスムーズにするため）
    @purchase_history.category_id = item.category_id
    @purchase_history.group_id = @group.id

    if @purchase_history.save
      # 保存できたらカレンダー画面へ
      redirect_to calendars_path, notice: "記録しました！"
    else
      # 失敗したら入力画面に戻す
      @categories = @group.categories
      render :new, status: :unprocessable_entity
    end
  end
  
  private

  def purchase_history_params
    params.require(:purchase_history).permit(:bought_at, :price, :quantity, :item_id, :category_id)
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
    params.require(:item).permit(:name, :is_subscription, :category_id, :price, :quantity)
  end
end

class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  def index
    @items = @group.items.includes(:category).order(created_at: :desc)

    @regular_items      = @items.regular      # 都度購入 (kind: 0)
    @subscription_items = @items.subscription # 定期購入 (kind: 1)
    @spot_items         = @items.spot         # スポット購入 (kind: 2)

    @item = @group.items.build

  end

  def create
    @item = @group.items.build(item_params)
    if @item.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to items_path, notice: "アイテムを追加しました！" }
      end
    else
      # 失敗した場合は通常の画面表示に戻す
      @items = @group.items.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @item = @group.items.find(params[:id])
    previously_checked = @item.is_checked
    if @item.update(item_params)
      # 💥 チェックを入れた瞬間（false -> true）の時だけ実行
      if !previously_checked && @item.is_checked
        @item.purchase_histories.create(group_id: @group.id, bought_at: Time.current)
        # 💥 ここで最新の平均サイクルを計算！
        @item.update_average_cycle
      end
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to items_path }
      end
    end
  end

  def destroy
    @item = @group.items.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to items_path, notice: "削除しました"}
    end
  end

  def bulk_update
    # 💥 params[:kind] を使って、その種類のチェックだけを外す
    items_to_reset = @group.items.where(kind: params[:kind], is_checked: true)
    items_to_reset.update_all(is_checked: false)

    redirect_to items_path, notice: "チェックをリセットしました"
  end

  private

  def set_group
    # ユーザーがグループに所属していない場合は、トップに戻して警告を出す
    @group = current_user.group
    redirect_to root_path, alert: "グループに参加してください" if @group.nil?
  end

  def item_params
    params.require(:item).permit(:name, :is_subscription, :is_checked, :category_id, :kind)
  end
end

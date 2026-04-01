class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  def index
    @items = @group.items.order(created_at: :desc)
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
    if @item.update(item_params)
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

  private

  def set_group
    # ユーザーがグループに所属していない場合は、トップに戻して警告を出す
    @group = current_user.group
    redirect_to root_path, alert: "グループに参加してください" if @group.nil?
  end

  def item_params
    params.require(:item).permit(:name, :is_subscription, :is_checked, :category_id)
  end
end

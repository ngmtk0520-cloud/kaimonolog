require 'ostruct'
class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  def index
    @group = current_user.group
    @categories = @group.categories.order(:created_at)
    @item = @group.items.build
    # 1. 選択されたカテゴリーを取得（未選択なら最初のカテゴリー）
    @current_category = if params[:category_id].present?
                          @categories.find(params[:category_id])
                        else
                          @categories.first
                        end

    @current_category_name = @current_category&.name
    # 2. そのカテゴリーに紐づくアイテムだけを表示
    if @current_category
      @items = @current_category.items.order(created_at: :desc)
    else
      @items = Item.none
    end

    # 💥 今日が予測日、または予測日を過ぎている「買い時」なアイテムを3件だけ抽出
    set_ai_suggestions
    
  end

  def create
    @item = @group.items.build(item_params)
    @item.kind ||= :regular

    if @item.save
      # 保存成功後は、そのアイテムのカテゴリーフォルダを開くようにリダイレクト
      @current_items_count = @item.category.items.count
      respond_to do |format|
        format.turbo_stream # これで create.turbo_stream.erb が動くようになる！
        format.html { redirect_to items_path(category_id: @item.category_id), notice: "追加しました！" }
      end
    else
      # 失敗時は index と同じ変数を揃える
      @categories = @group.categories.order(:created_at)
      @current_category = @categories.find_by(id: item_params[:category_id]) || @categories.first
      @items = @current_category ? @current_category.items.order(created_at: :desc) : Item.none
      
      set_ai_suggestions
      # AI予測などの変数も index と同様に必要ならここに書く
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @item = @group.items.find(params[:id])
    previously_checked = @item.is_checked

    if @item.update(item_params)
      # 💥 チェックを入れた瞬間（false -> true）の時だけ実行
      if !previously_checked && @item.is_checked 
        PurchaseHistory.create!(
          item_id: @item.id,
          item_name: @item.name,
          category_id: @item.category_id,
          group_id: @item.group_id,
          price: @item.price,
          bought_at: Time.current  # 今の日時で履歴を作る
        )
        @item.update(price: nil) 
      end
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to items_path }
      end
    end
  end

  def destroy
    @item = @group.items.find(params[:id])
    category = @item.category
    @item.destroy
    @current_items_count = @group.items.where(category: category).count

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@item),
          turbo_stream.update("category_#{category.id}_count", "#{@current_items_count}点")
        ]
      end
    end
  end

  def bulk_update
    target_category_id = params[:category_id]

    if target_category_id.present?
      items_to_reset = @group.items.where(category_id: target_category_id, is_checked: true)
    else
      items_to_reset = @group.items.where(is_checked: true)
    end

    items_to_reset.update_all(is_checked: false)
    redirect_to items_path(category_id: target_category_id), notice: "チェックをリセットしました"
  end

  private

  def set_group
    # ユーザーがグループに所属していない場合は、トップに戻して警告を出す
    @group = current_user.group
    redirect_to root_path, alert: "グループに参加してください" if @group.nil?
  end

  def item_params
    params.require(:item).permit(:name, :is_subscription, :is_checked, :category_id, :kind, :price)
  end

  def set_ai_suggestions
    @ai_suggestions = @group.items.subscription
                          .where("cycle_days > 0")
                          .select(&:due_soon?)
                          .first(3)
  end
end

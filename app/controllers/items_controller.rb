require 'ostruct'
class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  def index
    @items = @group.items.includes(:category).order(created_at: :desc)

    @regular_items      = @items.regular
    @subscription_items = @items.subscription
    @spot_items         = @items.spot

    # 💥 パラメータに応じて表示するものを切り替える
    @current_kind = params[:kind] || "regular"
    
    # 表示用の名前とカテゴリーをセット
    case @current_kind
    when "regular"
      @display_items = @regular_items
      @current_kind_name = "通常購入"
      @current_category = @group.categories.find_by(name: "通常購入")
    when "subscription"
      @display_items = @subscription_items
      @current_kind_name = "定期購入"
      @current_category = @group.categories.find_by(name: "定期購入")
    when "spot"
      @display_items = @spot_items
      @current_kind_name = "スポット購入"
      @current_category = @group.categories.find_by(name: "スポット購入")
    else
    # 💥 万が一変な値が来ても、通常購入を表示させる（保険）
      @display_items = @regular_items
      @current_kind_name = "通常購入"
    end

    @item = @group.items.build

    @expense_chart_data = @group.purchase_histories.where(bought_at: Time.current.all_month).joins(item: :category).group("categories.name").sum(:price)
    puts "📊 グラフデータの中身: #{@expense_chart_data}"

    # 💥 今日が予測日、または予測日を過ぎている「買い時」なアイテムを3件だけ抽出
    @ai_suggestions = @group.items.subscription.where("cycle_days > 0").select do |item|
      last_bought = item.purchase_histories.order(:bought_at).last&.bought_at || 10.days.ago
      next_date = (last_bought + item.cycle_days.days).to_date
      
      # 🚀 予測日が「3日後」までなら提案に載せる
      next_date <= Date.today + 3.days
    end.first(3)
  end

  def create
    @item = @group.items.build(item_params)
    if @item.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to items_path, notice: "アイテムを追加しました！" }
      end
    else
      # 💥 失敗時：View(index.html.erb)が動くために必要な変数をすべて用意する
      @items = @group.items.includes(:category).order(created_at: :desc)
      @regular_items = @items.regular
      @subscription_items = @items.subscription
      @spot_items = @items.spot
    
      # 💥 ここが重要！Viewで find_by している変数も必要です
      #（View側で直接 @group.categories.find_by... と書いているなら不要ですが、
      #  もしコントローラー側で定義している場合はここでも定義が必要です）
    
      @calendar_events = [] 
      @expense_chart_data = {}

      respond_to do |format|
        format.html { render :index, status: :unprocessable_content }
      end
    end
  end

  def update
    @item = @group.items.find(params[:id])
    previously_checked = @item.is_checked

    if @item.update(item_params.except(:price))
      # 💥 チェックを入れた瞬間（false -> true）の時だけ実行
      if !previously_checked && @item.is_checked
        @item.purchase_histories.create(group_id: @group.id, bought_at: Time.current, price: item_params[:price])
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
    params.require(:item).permit(:name, :is_subscription, :is_checked, :category_id, :kind, :price)
  end
end

class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: [:edit, :update, :destroy]

  def index
    @categories = current_user.group.categories
  end

  def create
    # ルーティングが /groups/:group_id/categories なので params[:group_id] で取得
    @group = Group.find(params[:group_id])
    @category = @group.categories.build(category_params)

    if @category.save
      redirect_to items_path, notice: "カテゴリー「#{@category.name}」を追加しました！"
    else
      # エラー時はひとまずホームに戻す
      redirect_to items_path, alert: "カテゴリーの作成に失敗しました"
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: "カテゴリー名を更新しました！"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # 「定期購入」はシステムの肝なので、念のためここでも削除をブロック
    if @category.name == "定期購入" || @category.name == "未分類"
      redirect_to categories_path, alert: "「#{@category.name}」カテゴリーはシステムの都合上、削除できません。"
    else
      unclassified = current_user.group.categories.find_or_create_by(name: "未分類")
      @category.items.update_all(category_id: unclassified.id)
      @category.destroy
      redirect_to categories_path, notice: "カテゴリーを削除しました。"
    end
  end

  private

  def set_category
    # セキュリティのため、現在のグループに属するカテゴリーのみを対象にする
    @category = current_user.group.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end


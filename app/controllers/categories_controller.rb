class CategoriesController < ApplicationController
  def create
    # ルーティングが /groups/:group_id/categories なので params[:group_id] で取得
    @group = Group.find(params[:group_id])
    @category = @group.categories.build(category_params)

    if @category.save
      redirect_to root_path, notice: "カテゴリー「#{@category.name}」を追加しました！"
    else
      # エラー時はひとまずホームに戻す
      redirect_to root_path, alert: "カテゴリーの作成に失敗しました"
    end
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end
end


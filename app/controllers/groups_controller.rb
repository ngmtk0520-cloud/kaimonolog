class GroupsController < ApplicationController
  before_action :authenticate_user!
  def create
    @group = Group.new(group_params)
    
    @group.invite_token = SecureRandom.hex(6) #12文字のランダムな鍵（招待コード）を自動生成
    if @group.save
      current_user.update(group_id: @group.id)
      redirect_to root_path, notice: "グループ「#{@group.name}」を作成しました！"
    else
      redirect_to root_path, alert: "グループの作成に失敗しました。"
    end
  end

  private

  def group_params
    params.require(:group).permit(:name)
  end
end

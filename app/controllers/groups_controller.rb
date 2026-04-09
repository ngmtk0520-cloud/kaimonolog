class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [:edit, :update]

  def create
    @group = Group.new(group_params)
    @group.invite_token = SecureRandom.hex(6) #12文字のランダムな鍵（招待コード）を自動生成
    if @group.save
      current_user.update(group_id: @group.id)
      redirect_to root_path, notice: "グループ「#{@group.name}」を作成しました！"
    else
      redirect_to root_path, alert: "グループの作成に失敗しました：#{@group.errors.full_messages.join(', ')}"
    end
  end

  def join
    group = Group.find_by(invite_token: params[:invite_token])

    if group
      current_user.update(group_id: group.id)
      redirect_to root_path, notice: "「#{group.name}に参加しましました」"
    else
      redirect_to root_path, alert: "招待コードが正しくありません"
    end
  end

  def leave
    if current_user.update(group_id: nil)
      redirect_to root_path, notice: "グループを抜けました"
    else
      redirect_to root_path, alert: "グループの退出に失敗しました。"
    end
  end

    def edit
      # 設定画面から飛んでくる編集画面
    end

    def update
      if @group.update(group_params)
        redirect_to settings_path, notice: "グループ名を更新しました"
      else
        render :edit, status: :unprocessable_entity
      end
    end

  

  private

  def set_group
    @group = current_user.group
  end

  def group_params
    params.require(:group).permit(:name)
  end
end

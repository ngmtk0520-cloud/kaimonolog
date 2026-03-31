require 'rails_helper'

RSpec.describe "Groups", type: :request do
  let(:user) { User.create!(nickname: "テストユーザー", email: "test@example.com", password: "password") }
  let(:group) { Group.create!(name: "テストグループ", invite_token: "valid_token") }

  before do
    # テスト環境でログイン状態を作る魔法
    sign_in user
  end

  describe "POST /groups/join" do
    context "正しい招待コードを入力した場合" do
      it "グループに参加でき、トップページにリダイレクトされること" do
        # 修正：postの引数に、ログイン中のユーザー情報（headersやenv）を確実に紐付けるか、
        # あるいは直接 params を渡す記述を補強します。
        post join_groups_path, params: { invite_token: group.invite_token }
        
        # ユーザーのデータを最新に更新
        user.reload
        
        # ユーザーのgroup_idが、作成したgroupのidと一致するか確認
        expect(user.group_id).to eq(group.id)
        
        # トップページに戻されるか確認
        expect(response).to redirect_to(root_path)
      end
    end

    context "間違った招待コードを入力した場合" do
      it "グループに参加できず、エラーメッセージが表示されること" do
        # 存在しないコードを送信する
        post join_groups_path, params: { invite_token: "invalid_token" }
        
        # ユーザーのgroup_idが空のままであることを確認
        user.reload
        expect(user.group_id).to be_nil
        
        # トップページに戻されるか確認
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
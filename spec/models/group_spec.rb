require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'グループ作成' do
    context 'グループ作成ができる場合' do
      it 'nameとinvite_tokenが存在すれば登録できる' do
        group = Group.new(name: 'テストグループ', invite_token: 'testtest')
        expect(group).to be_valid
      end
    end
    context 'グループ作成ができない場合' do
      it 'nameが空では作成できない' do
        group = Group.new(name: nil, invite_token: 'testtest')
        group.valid?
        expect(group.errors[:name]).to include("can't be blank")
      end
      it 'invite_tokenが重複したら作成できない' do
        group1 = Group.create!(name: 'テストグループ1', invite_token: 'testtest')
        group2 = Group.new(name: 'テストグループ2', invite_token: 'testtest')
        group2.valid?
        expect(group2.errors[:invite_token]).to include("has already been taken")
      end
    end
    # 詳細はテックキャンプの教材を参考に作成してみましょう！
  end
end
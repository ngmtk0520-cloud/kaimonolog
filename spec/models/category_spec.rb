require 'rails_helper'

RSpec.describe Category, type: :model do
  # 💥 invite_token を追加して、バリデーションを通るようにします
  let(:group) { Group.create!(name: "テスト家族", invite_token: "abcdef123456") }

  it "名前とグループがあれば有効であること" do
    category = Category.new(name: "野菜", group: group)
    expect(category).to be_valid
  end

  it "名前がなければ無効であること" do
    category = Category.new(name: nil, group: group)
    category.valid?
    expect(category.errors[:name]).to be_present
  end

  it "グループに属していなければ無効であること" do
    category = Category.new(name: "野菜", group: nil)
    expect(category).to_not be_valid
  end

  it "複数のItemを持つことができること（Associationの確認）" do
    category = Category.create!(name: "野菜", group: group)
    
    # Item作成時も、モデルのバリデーションに合わせて必要なデータを渡します
    item1 = Item.create!(name: "キャベツ", group: group, category: category, kind: :regular)
    item2 = Item.create!(name: "レタス", group: group, category: category, kind: :regular)
    
    category.reload
    expect(category.items).to include(item1, item2)
  end
end

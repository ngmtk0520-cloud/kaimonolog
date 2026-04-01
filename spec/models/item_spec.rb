require 'rails_helper'

RSpec.describe Item, type: :model do
  let(:group) { Group.create!(name: "テスト家族", invite_token: "abcdef123456") }
  let(:category) { Category.create!(name: "野菜", group: group) }

  it "名前、グループ、種類があれば有効であること" do
    item = Item.new(name: "牛乳", group: group, kind: :regular)
    expect(item).to be_valid
  end

  it "カテゴリーがなくても有効であること（optional: true の確認）" do
    item = Item.new(name: "牛乳", group: group, kind: :regular, category: nil)
    expect(item).to be_valid
  end

  it "名前がなければ無効であること" do
    item = Item.new(name: nil, group: group)
    item.valid?
    expect(item.errors[:name]).to be_present
  end

  it "kindが正しく設定できること（enumの確認）" do
    item = Item.new(name: "牛乳", group: group)
    
    item.kind = :subscription
    expect(item.subscription?).to be true
    
    item.kind = :spot
    expect(item.spot?).to be true
  end
end
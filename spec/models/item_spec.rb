require 'rails_helper'

RSpec.describe Item, type: :model do
  let(:group) { Group.create!(name: "テスト家族", invite_token: "abcdef123456") }
  let(:category) { Category.create!(name: "通常購入", group: group) }

  it "名前、グループ、種類、カテゴリーがあれば有効であること" do
    item = Item.new(name: "牛乳", group: group, kind: :regular, category: category)
    expect(item).to be_valid
  end

  it "名前がなければ無効であること" do
    item = Item.new(name: nil, group: group, kind: :regular, category: category)
    item.valid?
    expect(item.errors[:name]).to be_present
  end

  it "kindが正しく設定できること（enumの確認）" do
    item = Item.new(name: "牛乳", group: group, category: category)

    item.kind = :subscription
    expect(item.subscription?).to be true
    
    item.kind = :spot
    expect(item.spot?).to be true
  end

  it "購入履歴から平均サイクルを正しく計算すること" do
    item = Item.create!(name: "牛乳", group: group, kind: :subscription, category: category)
    
    # 履歴を3つ作る（間隔は 7日 と 7日）
    item.purchase_histories.create!(group_id: group.id, bought_at: 14.days.ago)
    item.purchase_histories.create!(group_id: group.id, bought_at: 7.days.ago)
    item.purchase_histories.create!(group_id: group.id, bought_at: Time.current)

    item.update_average_cycle
    expect(item.cycle_days).to eq(7)
  end

  it "カテゴリーがなければ無効であること（optional: false の確認）" do
    item = Item.new(name: "牛乳", group: group, kind: :regular, category: nil)
    expect(item).to_not be_valid
  end

  it "正しいカテゴリーがあれば有効であること" do
    item = Item.new(name: "牛乳", group: group, kind: :regular, category: category)
    expect(item).to be_valid
  end
end
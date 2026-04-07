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

  it "1週間以内に無くなりそうなアイテムを正しく抽出すること" do
    # 1. 予測対象（30日サイクルで25日前に購入 → あと5日で切れる）
    target_item = Item.create!(name: "対象品", group: group, kind: :subscription, category: category, cycle_days: 30)
    target_item.purchase_histories.create!(group_id: group.id, bought_at: 25.days.ago)

    # 2. 予測対象外（30日サイクルで5日前に購入 → まだ余裕あり）
    safe_item = Item.create!(name: "対象外", group: group, kind: :subscription, category: category, cycle_days: 30)
    safe_item.purchase_histories.create!(group_id: group.id, bought_at: 5.days.ago)

    # ItemsController#index で使っている抽出メソッドを呼び出す（例: .due_soon）
    results = Item.where(kind: :subscription).select { |i| i.due_soon? } # 実装に合わせて変更してください
    
    expect(results).to include(target_item)
    expect(results).not_to include(safe_item)
  end
end
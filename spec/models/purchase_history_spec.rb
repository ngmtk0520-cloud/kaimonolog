require 'rails_helper'

RSpec.describe PurchaseHistory, type: :model do
  let(:group) { Group.create!(name: "テスト家族", invite_token: "abcdef123456") }
  let(:item) { Item.create!(name: "牛乳", group: group, kind: :regular, category: category) }
  let(:category) { Category.create!(name: "通常購入", group: group) }

  it "カテゴリー、商品、グループ、購入日があれば有効であること" do
    history = PurchaseHistory.new(category: category, item: item, group: group, bought_at: Time.current)
    expect(history).to be_valid
  end

  it "購入日（bought_at）がなければ無効であること" do
    history = PurchaseHistory.new(category: category, item: item, group: group, bought_at: nil)
    expect(history).to_not be_valid
  end

  it "商品（item）がなければ無効であること" do
    history = PurchaseHistory.new(category: category, item: nil, group: group, bought_at: Time.current)
    expect(history).to_not be_valid
  end

  it "金額(price)が数値であれば有効であること" do
    history = PurchaseHistory.new(category: category, item: item, group: group, bought_at: Time.current, price: 500)
    expect(history).to be_valid
  end

  it "金額(price)が空でも有効であること（家計簿は任意入力なので）" do
    history = PurchaseHistory.new(category: category, item: item, group: group, bought_at: Time.current, price: nil)
    expect(history).to be_valid
  end

  it "金額(price)に文字列が入った場合は無効であること" do
    history = PurchaseHistory.new(category: category, item: item, group: group, bought_at: Time.current, price: "五百円")
    expect(history).to_not be_valid
  end

  it "カレンダーから新規登録する時は全ての項目が必須であること" do
    purchase_history = PurchaseHistory.new(category: category, item: item, group: group, bought_at: Time.current)
    expect(purchase_history).to be_valid
  end
end
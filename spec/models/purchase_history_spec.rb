require 'rails_helper'

RSpec.describe PurchaseHistory, type: :model do
  let(:group) { Group.create!(name: "テスト家族", invite_token: "abcdef123456") }
  let(:item) { Item.create!(name: "牛乳", group: group, kind: :regular) }

  it "商品、グループ、購入日があれば有効であること" do
    history = PurchaseHistory.new(item: item, group: group, bought_at: Time.current)
    expect(history).to be_valid
  end

  it "購入日（bought_at）がなければ無効であること" do
    history = PurchaseHistory.new(item: item, group: group, bought_at: nil)
    expect(history).to_not be_valid
  end

  it "商品（item）がなければ無効であること" do
    history = PurchaseHistory.new(item: nil, group: group, bought_at: Time.current)
    expect(history).to_not be_valid
  end
end
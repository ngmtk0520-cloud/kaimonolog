FactoryBot.define do
  factory :item do
    name { "MyString" }
    is_checked { false }
    is_subscription { false }
    last_bought_at { "2026-03-31 15:31:09" }
    cycle_days { 1 }
    group { nil }
  end
end

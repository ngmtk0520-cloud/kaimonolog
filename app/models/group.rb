class Group < ApplicationRecord
  has_many :users
  has_many :categories, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :purchase_histories, dependent: :destroy

  after_create :create_default_categories
  
  validates :name, presence: true
  validates :invite_token, presence: true, uniqueness: true

  private

  def create_default_categories
    categories.create!(name: "定期購入")
  end
end
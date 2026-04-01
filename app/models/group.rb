class Group < ApplicationRecord
  has_many :users
  has_many :items
  has_many :categories
  has_many :items, dependent: :destroy
  has_many :purchase_histories, dependent: :destroy
  
  validates :name, presence: true
  validates :invite_token, presence: true, uniqueness: true
end

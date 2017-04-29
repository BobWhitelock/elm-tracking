class Item < ApplicationRecord
  has_many :events

  validates :name, presence: true
end

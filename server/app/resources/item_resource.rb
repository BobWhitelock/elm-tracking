class ItemResource < JSONAPI::Resource
  attributes :name
  has_many :events
end

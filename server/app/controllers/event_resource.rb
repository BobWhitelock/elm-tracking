class EventResource < JSONAPI::Resource
  attributes :time
  has_one :item
end


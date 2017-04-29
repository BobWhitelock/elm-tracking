class Event < ApplicationRecord
  belongs_to :item

  def time
    # For now at least, the time an event occurred == the time it was created.
    created_at
  end
end

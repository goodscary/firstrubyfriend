class Event < ApplicationRecord
  has_prefix_id :evt

  belongs_to :user

  before_create do
    self.user_agent = Current.user_agent
    self.ip_address = Current.ip_address
  end
end

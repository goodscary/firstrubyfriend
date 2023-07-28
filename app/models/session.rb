class Session < ApplicationRecord
  ulid :user_id
  belongs_to :user

  kredis_flag :sudo, expires_in: 30.minutes

  before_create do
    self.user_agent = Current.user_agent
    self.ip_address = Current.ip_address
  end

  after_create { sudo.mark }

  after_create { user.events.create! action: "signed_in" }
  after_destroy { user.events.create! action: "signed_out" }
end

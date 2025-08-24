class EmailVerificationToken < ApplicationRecord
  has_prefix_id :evt

  belongs_to :user
end

class PasswordResetToken < ApplicationRecord
  has_prefix_id :prt

  belongs_to :user
end

class PasswordResetToken < ApplicationRecord
  ulid :user_id
  belongs_to :user
end

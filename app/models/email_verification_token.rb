class EmailVerificationToken < ApplicationRecord
  ulid :user_id
  belongs_to :user
end

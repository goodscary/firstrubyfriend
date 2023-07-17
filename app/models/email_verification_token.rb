class EmailVerificationToken < ApplicationRecord
  include ULID::Rails
  ulid :id, auto_generate: true
  ulid :user_id

  belongs_to :user
end

class UserLanguage < ApplicationRecord
  include ULID::Rails
  ulid :id, auto_generate: true
  ulid :user_id
  ulid :language_id

  belongs_to :user
  belongs_to :language

  validates :user_id, uniqueness: {scope: :language_id}
end

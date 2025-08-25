class UserLanguage < ApplicationRecord
  belongs_to :user
  belongs_to :language

  validates :user_id, uniqueness: {scope: :language_id}
end

class Language < ApplicationRecord
  include ULID::Rails
  ulid :id, auto_generate: true

  has_many :user_languages
  has_many :users, through: :user_languages

  validates :iso639_alpha3, presence: true, uniqueness: true
end

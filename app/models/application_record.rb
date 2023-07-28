class ApplicationRecord < ActiveRecord::Base
  include ULID::Rails
  ulid :id, auto_generate: true

  primary_abstract_class
end

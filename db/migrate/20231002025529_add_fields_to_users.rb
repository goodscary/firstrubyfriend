class AddFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :unsubscribed_at, :datetime
    add_column :users, :unsubscribed_reason, :string
    add_column :users, :available_as_mentor_at, :datetime
    add_column :users, :requested_mentorship_at, :datetime
    add_column :users, :city, :string
    add_column :users, :country_code, :string
    add_column :users, :lat, :decimal, precision: 10, scale: 6
    add_column :users, :lng, :decimal, precision: 10, scale: 6
    add_column :users, :demographic_year_of_birth, :integer
    add_column :users, :demographic_year_started_ruby, :integer
    add_column :users, :demographic_year_started_programming, :integer
    add_column :users, :demographic_underrepresented_group, :boolean

    add_index :users, :city
    add_index :users, :country_code
    add_index :users, [:lat, :lng]
  end
end

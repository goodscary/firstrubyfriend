class AddDemographicUnderrepresentedGroupDetailsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :demographic_underrepresented_group_details, :text
  end
end

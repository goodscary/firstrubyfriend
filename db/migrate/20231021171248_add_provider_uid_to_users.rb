class AddProviderUidToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :provider_uid, :string
  end
end

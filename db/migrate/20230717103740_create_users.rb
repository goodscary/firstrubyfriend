class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: false do |t|
      t.binary :id, limit: 16, primary_key: true
      t.string :first_name
      t.string :last_name
      t.string :email, null: false, index: {unique: true}
      t.string :password_digest, null: false

      t.boolean :verified, null: false, default: false

      t.string :provider
      t.string :uid

      t.timestamps
    end

    add_index :users, [:provider, :uid], unique: true
  end
end

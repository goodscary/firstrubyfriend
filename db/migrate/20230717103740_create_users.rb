class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email, null: false, index: {unique: true}
      t.string :password_digest, null: false

      t.boolean :verified, null: false, default: false

      t.string :provider
      t.string :uid

      t.timestamps
    end
  end
end

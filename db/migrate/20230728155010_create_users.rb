class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: false do |t|
      t.binary :id, limit: 16, primary_key: true, auto_generate: true

      t.string :email, null: false, index: {unique: true}
      t.string :password_digest, null: false

      t.boolean :verified, null: false, default: false

      t.timestamps
    end
  end
end

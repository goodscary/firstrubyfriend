class CreatePasswordResetTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :password_reset_tokens, id: false do |t|
      t.binary :id, limit: 16, primary_key: true, auto_generate: true

      t.references :user, null: false, foreign_key: true, type: :binary
    end
  end
end

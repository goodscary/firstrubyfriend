class CreateEmailVerificationTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :email_verification_tokens, id: false do |t|
      t.binary :id, limit: 16, auto_generate: true, primary_key: true

      t.references :user, type: :binary, foreign_key: true, index: true
      t.timestamps
    end
  end
end

class CreateUserLanguages < ActiveRecord::Migration[6.1]
  def change
    create_table :user_languages, id: :binary, limit: 16, force: :cascade do |t|
      t.binary :user_id, limit: 16, null: false, foreign_key: true
      t.binary :language_id, limit: 16, null: false, foreign_key: true

      t.timestamps
    end
  end
end

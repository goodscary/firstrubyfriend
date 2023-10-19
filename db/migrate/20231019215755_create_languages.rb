class CreateLanguages < ActiveRecord::Migration[7.0]
  def change
    create_table :languages, id: :binary, limit: 16, force: :cascade do |t|
      t.string :iso639_alpha3, null: false, unique: true
      t.string :iso639_alpha2
      t.string :english_name
      t.string :french_name
      t.string :local_name

      t.timestamps
    end
  end
end

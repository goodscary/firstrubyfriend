class DropImportReports < ActiveRecord::Migration[8.0]
  def change
    drop_table :import_reports do |t|
      t.string :report_id, null: false
      t.string :import_type
      t.string :status
      t.integer :imported_count, default: 0
      t.integer :failed_count, default: 0
      t.text :error_messages
      t.text :row_errors
      t.text :metadata
      t.datetime :started_at
      t.datetime :completed_at
      t.timestamps
    end
  end
end

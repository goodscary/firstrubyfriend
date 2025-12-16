module CsvImportable
  extend ActiveSupport::Concern

  class_methods do
    def import_from_csv(csv_content, use_transaction: false)
      result = ImportResult.new

      begin
        csv = CSV.parse(csv_content, headers: true, header_converters: :downcase)

        missing = csv_import_missing_headers(csv.headers)
        if missing.any?
          result.add_error("Missing required headers: #{missing.join(", ")}")
          return result
        end

        if use_transaction
          transaction do
            process_csv_rows(csv, result)
            raise ActiveRecord::Rollback unless result.success?
          end
        else
          process_csv_rows(csv, result)
        end
      rescue CSV::MalformedCSVError => e
        result.add_error("CSV parsing error: #{e.message}")
      rescue => e
        result.add_error("Import failed: #{e.message}")
      end

      result
    end

    private

    def process_csv_rows(csv, result)
      csv.each_with_index do |row, index|
        row_result = process_csv_row(row, index)

        if row_result[:success]
          result.increment_imported
        else
          result.add_row_error(index + 2, row_result[:error])
        end
      end
    end

    def csv_import_missing_headers(headers)
      csv_import_required_headers - headers.map(&:to_s)
    end

    def csv_import_required_headers
      []
    end

    def process_csv_row(row, index)
      raise NotImplementedError, "Subclasses must implement process_csv_row"
    end

    def map_csv_row(row, header_mapping)
      mapped = {}
      header_mapping.each do |csv_header, field_name|
        mapped[field_name] = row[csv_header]&.strip
      end
      mapped
    end
  end
end

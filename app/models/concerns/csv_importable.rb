require "csv"

module CsvImportable
  extend ActiveSupport::Concern

  class_methods do
    def import_from_csv(csv_content, rate_limit_delay: nil)
      imported = 0
      failed = 0

      csv = CSV.parse(csv_content, headers: true, header_converters: :downcase)

      missing = csv_import_required_headers - csv.headers.map(&:to_s)
      if missing.any?
        Rails.logger.error "[Import] Missing required headers: #{missing.join(', ')}"
        return false
      end

      csv.each_with_index do |row, index|
        sleep(rate_limit_delay) if rate_limit_delay && index > 0

        result = process_csv_row(row, index)
        if result[:success]
          imported += 1
        else
          failed += 1
          Rails.logger.info "[Import] Row #{index + 2}: #{result[:error]}"
        end
      end

      Rails.logger.info "[Import] Complete: #{imported} imported, #{failed} failed"
      failed == 0
    rescue CSV::MalformedCSVError => e
      Rails.logger.error "[Import] CSV parsing error: #{e.message}"
      false
    end

    private

    def csv_import_required_headers
      []
    end

    def process_csv_row(row, index)
      raise NotImplementedError, "Subclasses must implement process_csv_row"
    end
  end
end

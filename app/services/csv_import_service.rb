class CsvImportService
  attr_reader :csv_content, :options

  def initialize(csv_content, options = {})
    @csv_content = csv_content
    @options = options
  end

  def import
    result = ImportResult.new

    begin
      csv = parse_csv(csv_content)

      if !valid_headers?(csv.headers)
        result.add_error("Missing required headers: #{missing_headers(csv.headers).join(", ")}")
        return result
      end

      if options[:use_transaction]
        ActiveRecord::Base.transaction do
          process_csv(csv, result)
          raise ActiveRecord::Rollback if !result.success?
        end
      else
        process_csv(csv, result)
      end
    rescue CSV::MalformedCSVError => e
      result.add_error("CSV parsing error: #{e.message}")
    rescue => e
      result.add_error("Import failed: #{e.message}")
    end

    result
  end

  protected

  def process_csv(csv, result)
    csv.each_with_index do |row, index|
      row_result = process_row(row, index)

      if row_result[:success]
        result.increment_imported
      else
        result.add_row_error(index + 2, row_result[:error]) # +2 for 1-based and header row
      end
    end
  end

  def parse_csv(content)
    CSV.parse(content, headers: true, header_converters: :downcase)
  end

  def valid_headers?(headers)
    missing_headers(headers).empty?
  end

  def missing_headers(headers)
    required_headers - headers.map(&:to_s)
  end

  def required_headers
    []
  end

  def process_row(row, index)
    raise NotImplementedError, "Subclasses must implement process_row"
  end
end

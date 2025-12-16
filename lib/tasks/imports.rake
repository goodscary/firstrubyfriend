namespace :imports do
  desc "Import mentors from CSV file"
  task :mentors, [:file_path] => :environment do |t, args|
    file_path = args[:file_path]

    unless file_path && File.exist?(file_path)
      puts "Error: File not found at #{file_path}"
      exit 1
    end

    puts "Importing mentors from #{file_path}..."

    csv_content = File.read(file_path)
    report_id = "rake_mentor_#{Time.current.strftime("%Y%m%d_%H%M%S")}"

    result = ImportJob.perform_now("mentor", csv_content, report_id: report_id)

    puts result.summary
  end

  desc "Import applicants from CSV file"
  task :applicants, [:file_path] => :environment do |t, args|
    file_path = args[:file_path]

    unless file_path && File.exist?(file_path)
      puts "Error: File not found at #{file_path}"
      exit 1
    end

    puts "Importing applicants from #{file_path}..."

    csv_content = File.read(file_path)
    report_id = "rake_applicant_#{Time.current.strftime("%Y%m%d_%H%M%S")}"

    result = ImportJob.perform_now("applicant", csv_content, report_id: report_id)

    puts result.summary
  end

  desc "Import matches from CSV file"
  task :matches, [:file_path] => :environment do |t, args|
    file_path = args[:file_path]

    unless file_path && File.exist?(file_path)
      puts "Error: File not found at #{file_path}"
      exit 1
    end

    puts "Importing matches from #{file_path}..."

    csv_content = File.read(file_path)
    report_id = "rake_match_#{Time.current.strftime("%Y%m%d_%H%M%S")}"

    result = ImportJob.perform_now("match", csv_content, report_id: report_id)

    puts result.summary
  end

  desc "Backfill email dates for all mentorships"
  task backfill_emails: :environment do
    puts "Backfilling email dates for mentorships..."

    result = Mentorship.backfill_email_dates(audit: true)

    puts result.summary

    if result.audit_trail
      puts "\nAudit Trail:"
      result.audit_trail.each do |entry|
        puts "  Mentorship #{entry[:mentorship_id]}: #{entry[:backfilled_fields].size} fields backfilled"
      end
    end
  end

  desc "Show import report by ID"
  task :report, [:report_id] => :environment do |t, args|
    report_id = args[:report_id]

    unless report_id
      puts "Error: Please provide a report ID"
      puts "Usage: rails imports:report[report_id]"
      exit 1
    end

    report = ImportReport.find_by(report_id: report_id)

    if report
      puts report.summary
    else
      puts "Error: Report not found with ID: #{report_id}"
      exit 1
    end
  end

  desc "List recent import reports"
  task reports: :environment do
    reports = ImportReport.recent.limit(20)

    if reports.any?
      puts "Recent Import Reports:"
      puts "-" * 80

      reports.each do |report|
        status_color = case report.status
        when "completed" then "\e[32m" # Green
        when "failed" then "\e[31m" # Red
        when "processing" then "\e[33m" # Yellow
        else ""
        end

        puts "#{status_color}#{report.report_id.ljust(20)}\e[0m" \
          "#{report.import_type.ljust(10)}" \
          "#{report.status.ljust(12)}" \
          "#{(report.imported_count || 0).to_s.rjust(8)}" \
          "#{(report.failed_count || 0).to_s.rjust(8)}" \
          "  #{report.created_at&.strftime("%Y-%m-%d %H:%M")}"
      end
    else
      puts "No import reports found"
    end
  end

  desc "Full import workflow - mentors, applicants, then matches"
  task :full_import, [:mentors_file, :applicants_file, :matches_file] => :environment do |t, args|
    mentors_file = args[:mentors_file]
    applicants_file = args[:applicants_file]
    matches_file = args[:matches_file]

    unless mentors_file && applicants_file && matches_file
      puts "Error: All three CSV files are required"
      puts "Usage: rails imports:full_import[mentors.csv,applicants.csv,matches.csv]"
      exit 1
    end

    [mentors_file, applicants_file, matches_file].each do |file|
      unless File.exist?(file)
        puts "Error: File not found: #{file}"
        exit 1
      end
    end

    Time.current.strftime("%Y%m%d_%H%M%S")

    puts "Starting full import workflow..."
    puts "1. Importing mentors..."
    Rake::Task["imports:mentors"].invoke(mentors_file)

    puts "\n2. Importing applicants..."
    Rake::Task["imports:applicants"].invoke(applicants_file)

    puts "\n3. Importing matches..."
    Rake::Task["imports:matches"].invoke(matches_file)

    puts "\n4. Backfilling email dates..."
    Rake::Task["imports:backfill_emails"].invoke

    puts "\nFull import workflow completed!"
  end
end

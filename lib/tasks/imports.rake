namespace :imports do
  desc "Import mentors from CSV file"
  task :mentors, [:file_path] => :environment do |t, args|
    file_path = args[:file_path]
    abort "Usage: rails imports:mentors[path/to/file.csv]" unless file_path && File.exist?(file_path)

    puts "Importing mentors from #{file_path}..."
    success = User.import_mentors_from_csv(File.read(file_path))
    exit(success ? 0 : 1)
  end

  desc "Import applicants from CSV file"
  task :applicants, [:file_path] => :environment do |t, args|
    file_path = args[:file_path]
    abort "Usage: rails imports:applicants[path/to/file.csv]" unless file_path && File.exist?(file_path)

    puts "Importing applicants from #{file_path}..."
    success = User.import_applicants_from_csv(File.read(file_path))
    exit(success ? 0 : 1)
  end

  desc "Import matches from CSV file (date parsed from filename like '23-Sep-Table 1.csv' or passed as second arg)"
  task :matches, [:file_path, :match_date] => :environment do |t, args|
    file_path = args[:file_path]
    abort "Usage: rails imports:matches[path/to/file.csv] or rails imports:matches[path/to/file.csv,2023-09-01]" unless file_path && File.exist?(file_path)

    match_date = if args[:match_date].present?
      Date.parse(args[:match_date])
    else
      parse_date_from_filename(File.basename(file_path))
    end

    abort "Could not determine match date from filename. Use: rails imports:matches[file.csv,2023-09-01]" unless match_date

    puts "Importing matches from #{file_path} with date #{match_date}..."
    success = Mentorship.import_matches_from_csv(File.read(file_path), match_date: match_date)

    if success
      puts "\nBackfilling email dates..."
      Mentorship.backfill_email_dates
    end

    exit(success ? 0 : 1)
  end

  def parse_date_from_filename(filename)
    # Parse filenames like "23-Sep-Table 1.csv" or "24-Jan-Table 1.csv"
    if filename =~ /^(\d{2})-([A-Za-z]{3})/
      year_suffix = $1.to_i
      month_abbrev = $2
      year = year_suffix >= 90 ? 1900 + year_suffix : 2000 + year_suffix
      Date.parse("1 #{month_abbrev} #{year}")
    end
  rescue Date::Error
    nil
  end

  desc "Backfill email dates for all mentorships"
  task backfill_emails: :environment do
    puts "Backfilling email dates..."
    success = Mentorship.backfill_email_dates
    exit(success ? 0 : 1)
  end

  desc "Full import workflow"
  task :full_import, [:mentors_file, :applicants_file, :matches_file, :match_date] => :environment do |t, args|
    abort "Usage: rails imports:full_import[mentors.csv,applicants.csv,matches.csv,2023-09-01]" unless args[:mentors_file] && args[:applicants_file] && args[:matches_file]

    [args[:mentors_file], args[:applicants_file], args[:matches_file]].each do |f|
      abort "File not found: #{f}" unless File.exist?(f)
    end

    match_date = if args[:match_date].present?
      Date.parse(args[:match_date])
    else
      parse_date_from_filename(File.basename(args[:matches_file]))
    end

    abort "Could not determine match date. Pass it as fourth argument." unless match_date

    puts "=== Importing Mentors ==="
    User.import_mentors_from_csv(File.read(args[:mentors_file]))

    puts "\n=== Importing Applicants ==="
    User.import_applicants_from_csv(File.read(args[:applicants_file]))

    puts "\n=== Importing Matches (date: #{match_date}) ==="
    Mentorship.import_matches_from_csv(File.read(args[:matches_file]), match_date: match_date)

    puts "\n=== Backfilling Email Dates ==="
    Mentorship.backfill_email_dates

    puts "\nDone!"
  end
end

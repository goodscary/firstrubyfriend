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

  desc "Import matches from CSV file"
  task :matches, [:file_path] => :environment do |t, args|
    file_path = args[:file_path]
    abort "Usage: rails imports:matches[path/to/file.csv]" unless file_path && File.exist?(file_path)

    puts "Importing matches from #{file_path}..."
    success = Mentorship.import_matches_from_csv(File.read(file_path))

    if success
      puts "\nBackfilling email dates..."
      Mentorship.backfill_email_dates
    end

    exit(success ? 0 : 1)
  end

  desc "Backfill email dates for all mentorships"
  task backfill_emails: :environment do
    puts "Backfilling email dates..."
    success = Mentorship.backfill_email_dates
    exit(success ? 0 : 1)
  end

  desc "Full import workflow"
  task :full_import, [:mentors_file, :applicants_file, :matches_file] => :environment do |t, args|
    abort "Usage: rails imports:full_import[mentors.csv,applicants.csv,matches.csv]" unless args[:mentors_file] && args[:applicants_file] && args[:matches_file]

    [args[:mentors_file], args[:applicants_file], args[:matches_file]].each do |f|
      abort "File not found: #{f}" unless File.exist?(f)
    end

    puts "=== Importing Mentors ==="
    User.import_mentors_from_csv(File.read(args[:mentors_file]))

    puts "\n=== Importing Applicants ==="
    User.import_applicants_from_csv(File.read(args[:applicants_file]))

    puts "\n=== Importing Matches ==="
    Mentorship.import_matches_from_csv(File.read(args[:matches_file]))

    puts "\n=== Backfilling Email Dates ==="
    Mentorship.backfill_email_dates

    puts "\nDone!"
  end
end

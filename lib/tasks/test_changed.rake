namespace :test do
  desc "Run tests for changed files compared to main branch"
  task :changed do
    # Get changed files from different Git states
    changed_filenames = gather_changed_filenames

    # Filter for test files only
    test_files = changed_filenames.select { |f| f.end_with?("_test.rb") && File.exist?(f) }

    if test_files.empty?
      puts "\n✗ No test files found in changed files."
      puts "\nChanged files (#{changed_filenames.size}):"
      changed_filenames.each { |f| puts "  #{f}" }
      exit(0)
    end

    puts "\n✓ Found #{test_files.size} test file(s) to run:"
    test_files.each { |f| puts "  #{f}" }
    puts ""

    # Use system instead of exec for better error handling
    success = system("bin/rails", "test", *test_files)
    exit(success ? 0 : 1)
  end

  private

  def gather_changed_filenames
    files = Set.new

    # Files changed between base branch and current HEAD
    if system("git rev-parse main", out: File::NULL, err: File::NULL)
      files.merge(`git diff --name-only main...HEAD 2>/dev/null`.split("\n"))
    end

    # Staged files
    files.merge(`git diff --cached --name-only 2>/dev/null`.split("\n"))

    # Unstaged files
    files.merge(`git diff --name-only 2>/dev/null`.split("\n"))

    # Remove empty strings and return sorted array
    files.reject!(&:empty?)
    files.to_a.sort
  end
end

require "test_helper"
require "csv"

class MentorshipTest < ActiveSupport::TestCase
  def setup
    @mentor = users.mentor
    @applicant = users.applicant
    Current.user_agent = "Mozilla/5.0 Test Browser"
    Current.ip_address = "127.0.0.1"
  end

  class Validations < MentorshipTest
    test "saves with valid mentor and applicant" do
      mentorship = Mentorship.new(mentor: users.basic, applicant: users.unverified, standing: "active")
      assert mentorship.save
    end

    test "rejects same user as mentor and applicant" do
      mentor = users.mentor
      mentorship = Mentorship.new(mentor: mentor, applicant: mentor, standing: "active")

      assert_not mentorship.save
      assert_includes mentorship.errors[:mentor], "cannot be the same as applicant"
    end

    test "requires standing presence" do
      mentorship = Mentorship.new(mentor: users.basic, applicant: users.unverified)
      assert_not mentorship.valid?
      assert_includes mentorship.errors[:standing], "can't be blank"
    end
  end

  class Standing < MentorshipTest
    test "accepts valid standing enum options" do
      active_mentorship = Mentorship.new(mentor: users.mentor, applicant: users.applicant, standing: "active")
      assert_equal "active", active_mentorship.standing
    end

    test "rejects invalid standing enum option" do
      assert_raises(ArgumentError) { Mentorship.new(mentor: users.mentor, applicant: users.applicant, standing: "invalid_standing") }
    end

    test "can end a mentorship" do
      mentorship = Mentorship.create!(mentor: users.basic, applicant: users.unverified, standing: "active")
      mentorship.update!(standing: "ended")

      assert_equal "ended", mentorship.standing
      assert_not_includes Mentorship.active, mentorship
    end
  end

  class PrefixedId < MentorshipTest
    test "generates prefixed ID with mnt_ prefix" do
      mentorship = Mentorship.create!(mentor: users.basic, applicant: users.unverified, standing: "active")
      assert mentorship.prefix_id.start_with?("mnt_")
      assert mentorship.prefix_id.length > 4
    end

    test "finds mentorship by prefixed ID" do
      mentorship = Mentorship.create!(mentor: users.basic, applicant: users.unverified, standing: "active")
      found_mentorship = Mentorship.find_by_prefix_id(mentorship.prefix_id)
      assert_equal mentorship, found_mentorship
    end

    test "returns nil for invalid prefixed ID" do
      result = Mentorship.find_by_prefix_id("mnt_invalid")
      assert_nil result
    end
  end

  class Scopes < MentorshipTest
    test "active scope includes active mentorships" do
      active_mentorship = mentorships.active_no_emails_sent
      assert_equal "active", active_mentorship.standing
      assert_includes Mentorship.active, active_mentorship
    end

    test "active scope excludes ended mentorships" do
      ended_mentorship = Mentorship.create!(mentor: users.basic, applicant: users.unverified, standing: "ended")
      assert_not_includes Mentorship.active, ended_mentorship
    end
  end

  class FindMatchesForApplicant < MentorshipTest
    test "delegates to MentorshipMatcher" do
      result = Mentorship.find_matches_for_applicant(@applicant)
      assert_kind_of Array, result
    end
  end

  class ImportMatchesFromCsv < MentorshipTest
    setup do
      @test_mentor1 = User.create!(
        email: "import_mentor1@example.com",
        first_name: "Mentor",
        last_name: "One",
        skip_password_validation: true,
        available_as_mentor_at: 1.month.ago
      )

      @test_mentor2 = User.create!(
        email: "import_mentor2@example.com",
        first_name: "Mentor",
        last_name: "Two",
        skip_password_validation: true,
        available_as_mentor_at: 1.month.ago
      )

      @test_applicant1 = User.create!(
        email: "import_applicant1@example.com",
        first_name: "Applicant",
        last_name: "One",
        skip_password_validation: true,
        requested_mentorship_at: 1.month.ago
      )

      @test_applicant2 = User.create!(
        email: "import_applicant2@example.com",
        first_name: "Applicant",
        last_name: "Two",
        skip_password_validation: true,
        requested_mentorship_at: 1.month.ago
      )

      @match_date = Date.new(2024, 1, 15)

      @valid_csv = CSV.generate do |csv|
        csv << ["Applicant", "Country", "City", "Mentor"]
        csv << ["import_applicant1@example.com", "USA", "Portland", "import_mentor1@example.com"]
        csv << ["import_applicant2@example.com", "Canada", "Toronto", "import_mentor2@example.com"]
      end

      @reassignment_csv = CSV.generate do |csv|
        csv << ["Applicant", "Country", "City", "Mentor"]
        csv << ["import_applicant1@example.com", "USA", "Portland", "import_mentor1@example.com"]
        csv << ["import_applicant1@example.com", "USA", "Portland", "import_mentor2@example.com"]
      end

      @orphaned_match_csv = CSV.generate do |csv|
        csv << ["Applicant", "Country", "City", "Mentor"]
        csv << ["nonexistent@example.com", "USA", "Portland", "import_mentor1@example.com"]
        csv << ["import_applicant1@example.com", "USA", "Portland", "nonexistent@example.com"]
      end
    end

    test "imports matches successfully" do
      assert_difference "Mentorship.count", 2 do
        success = Mentorship.import_matches_from_csv(@valid_csv, match_date: @match_date)
        assert success
      end

      mentorship1 = Mentorship.find_by(mentor: @test_mentor1, applicant: @test_applicant1)
      assert_not_nil mentorship1
      assert_equal "active", mentorship1.standing

      mentorship2 = Mentorship.find_by(mentor: @test_mentor2, applicant: @test_applicant2)
      assert_not_nil mentorship2
      assert_equal "active", mentorship2.standing
    end

    test "handles match reassignments by voiding previous match" do
      assert_difference "Mentorship.count", 2 do
        Mentorship.import_matches_from_csv(@reassignment_csv, match_date: @match_date)
      end

      old_mentorship = Mentorship.find_by(mentor: @test_mentor1, applicant: @test_applicant1)
      assert_equal "ended", old_mentorship.standing

      new_mentorship = Mentorship.find_by(mentor: @test_mentor2, applicant: @test_applicant1)
      assert_equal "active", new_mentorship.standing
    end

    test "reports orphaned matches" do
      success = Mentorship.import_matches_from_csv(@orphaned_match_csv, match_date: @match_date)
      assert_not success
    end

    test "validates required headers" do
      invalid_csv = CSV.generate do |csv|
        csv << ["Email", "Something"]
        csv << ["test@example.com", "mentor@example.com"]
      end

      success = Mentorship.import_matches_from_csv(invalid_csv, match_date: @match_date)
      assert_not success
    end

    test "prevents duplicate active matches" do
      Mentorship.create!(
        mentor: @test_mentor1,
        applicant: @test_applicant1,
        standing: "active"
      )

      success = Mentorship.import_matches_from_csv(@valid_csv, match_date: @match_date)
      # One succeeds, one fails (duplicate), so overall returns false
      assert_not success
    end

    test "handles case-insensitive email matching" do
      csv_with_mixed_case = CSV.generate do |csv|
        csv << ["Applicant", "Mentor"]
        csv << ["IMPORT_APPLICANT1@EXAMPLE.COM", "IMPORT_MENTOR1@EXAMPLE.COM"]
      end

      assert_difference "Mentorship.count", 1 do
        success = Mentorship.import_matches_from_csv(csv_with_mixed_case, match_date: @match_date)
        assert success
      end

      mentorship = Mentorship.find_by(mentor: @test_mentor1, applicant: @test_applicant1)
      assert_not_nil mentorship
    end

    test "sets created_at from match_date parameter" do
      csv = CSV.generate do |csv|
        csv << ["Applicant", "Mentor"]
        csv << ["import_applicant1@example.com", "import_mentor1@example.com"]
      end

      Mentorship.import_matches_from_csv(csv, match_date: Date.new(2023, 9, 1))

      mentorship = Mentorship.find_by(applicant: @test_applicant1, mentor: @test_mentor1)
      assert_equal Date.new(2023, 9, 1), mentorship.created_at.to_date
    end

    test "imports CSV with extra columns (ignores them)" do
      # Extra columns like Country, City, Gone should be silently ignored
      csv_with_extras = CSV.generate do |csv|
        csv << ["Applicant", "Country", "City", "Mentor", "Gone", "Notes"]
        csv << ["import_applicant1@example.com", "USA", "Portland", "import_mentor1@example.com", "", "Some notes"]
        csv << ["import_applicant2@example.com", "UK", "London", "import_mentor2@example.com", "yes", ""]
      end

      assert_difference "Mentorship.count", 2 do
        success = Mentorship.import_matches_from_csv(csv_with_extras, match_date: @match_date)
        assert success
      end

      # All matches should be active (Gone column is ignored)
      mentorship1 = Mentorship.find_by(mentor: @test_mentor1, applicant: @test_applicant1)
      assert_equal "active", mentorship1.standing

      mentorship2 = Mentorship.find_by(mentor: @test_mentor2, applicant: @test_applicant2)
      assert_equal "active", mentorship2.standing
    end
  end

  class BackfillEmailDates < MentorshipTest
    setup do
      Mentorship.destroy_all

      @backfill_mentor = User.create!(
        email: "backfill_mentor@example.com",
        first_name: "Mentor",
        last_name: "User",
        skip_password_validation: true
      )

      @backfill_applicant = User.create!(
        email: "backfill_applicant@example.com",
        first_name: "Applicant",
        last_name: "User",
        skip_password_validation: true
      )

      @old_mentorship = Mentorship.create!(
        mentor: @backfill_mentor,
        applicant: @backfill_applicant,
        standing: "ended",
        created_at: 7.months.ago
      )

      @recent_mentorship = Mentorship.create!(
        mentor: User.create!(email: "backfill_mentor2@example.com", first_name: "M", last_name: "2", skip_password_validation: true),
        applicant: User.create!(email: "backfill_applicant2@example.com", first_name: "A", last_name: "2", skip_password_validation: true),
        standing: "active",
        created_at: 2.months.ago
      )

      @new_mentorship = Mentorship.create!(
        mentor: User.create!(email: "backfill_mentor3@example.com", first_name: "M", last_name: "3", skip_password_validation: true),
        applicant: User.create!(email: "backfill_applicant3@example.com", first_name: "A", last_name: "3", skip_password_validation: true),
        standing: "active",
        created_at: 1.week.ago
      )
    end

    test "backfills email dates based on mentorship creation date" do
      success = Mentorship.backfill_email_dates
      assert success

      @old_mentorship.reload
      assert_not_nil @old_mentorship.applicant_month_1_email_sent_at
      assert_not_nil @old_mentorship.applicant_month_2_email_sent_at
      assert_not_nil @old_mentorship.applicant_month_3_email_sent_at
      assert_not_nil @old_mentorship.applicant_month_4_email_sent_at
      assert_not_nil @old_mentorship.applicant_month_5_email_sent_at
      assert_not_nil @old_mentorship.applicant_month_6_email_sent_at

      assert_not_nil @old_mentorship.mentor_month_1_email_sent_at
      assert_not_nil @old_mentorship.mentor_month_2_email_sent_at
      assert_not_nil @old_mentorship.mentor_month_3_email_sent_at
      assert_not_nil @old_mentorship.mentor_month_4_email_sent_at
      assert_not_nil @old_mentorship.mentor_month_5_email_sent_at
      assert_not_nil @old_mentorship.mentor_month_6_email_sent_at
    end

    test "only backfills emails for elapsed months" do
      Mentorship.backfill_email_dates

      @recent_mentorship.reload
      assert_not_nil @recent_mentorship.applicant_month_1_email_sent_at
      assert_not_nil @recent_mentorship.applicant_month_2_email_sent_at
      assert_nil @recent_mentorship.applicant_month_3_email_sent_at
      assert_nil @recent_mentorship.applicant_month_4_email_sent_at

      assert_not_nil @recent_mentorship.mentor_month_1_email_sent_at
      assert_not_nil @recent_mentorship.mentor_month_2_email_sent_at
      assert_nil @recent_mentorship.mentor_month_3_email_sent_at
      assert_nil @recent_mentorship.mentor_month_4_email_sent_at
    end

    test "does not backfill for very recent mentorships" do
      Mentorship.backfill_email_dates

      @new_mentorship.reload
      assert_nil @new_mentorship.applicant_month_1_email_sent_at
      assert_nil @new_mentorship.mentor_month_1_email_sent_at
    end

    test "skips mentorships that already have email dates" do
      @old_mentorship.update!(
        applicant_month_1_email_sent_at: 5.months.ago,
        mentor_month_1_email_sent_at: 5.months.ago
      )

      Mentorship.backfill_email_dates

      @old_mentorship.reload
      assert_equal 5.months.ago.to_date, @old_mentorship.applicant_month_1_email_sent_at.to_date
      assert_equal 5.months.ago.to_date, @old_mentorship.mentor_month_1_email_sent_at.to_date

      assert_not_nil @old_mentorship.applicant_month_2_email_sent_at
    end

    test "calculates correct email send dates" do
      Mentorship.backfill_email_dates

      @old_mentorship.reload
      created = @old_mentorship.created_at

      month1_expected = created + 1.month
      assert_not_nil @old_mentorship.applicant_month_1_email_sent_at
      assert_in_delta month1_expected.to_i, @old_mentorship.applicant_month_1_email_sent_at.to_i, 3.days.to_i

      month2_expected = created + 2.months
      assert_not_nil @old_mentorship.applicant_month_2_email_sent_at
      assert_in_delta month2_expected.to_i, @old_mentorship.applicant_month_2_email_sent_at.to_i, 3.days.to_i

      month6_expected = created + 6.months
      assert_not_nil @old_mentorship.applicant_month_6_email_sent_at
      assert_in_delta month6_expected.to_i, @old_mentorship.applicant_month_6_email_sent_at.to_i, 3.days.to_i
    end

    test "handles specific mentorship backfill" do
      result = @old_mentorship.backfill_email_dates_for_mentorship

      assert result[:success]
      assert_equal 12, result[:backfilled_count]

      @old_mentorship.reload
      assert_not_nil @old_mentorship.applicant_month_6_email_sent_at
      assert_not_nil @old_mentorship.mentor_month_6_email_sent_at
    end
  end
end

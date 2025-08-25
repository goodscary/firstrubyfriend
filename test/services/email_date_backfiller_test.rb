require "test_helper"

class EmailDateBackfillerTest < ActiveSupport::TestCase
  setup do
    # Clean up any existing test data
    Mentorship.destroy_all
    User.destroy_all

    @mentor = User.create!(
      email: "mentor@example.com",
      first_name: "Mentor",
      last_name: "User",
      skip_password_validation: true
    )

    @applicant = User.create!(
      email: "applicant@example.com",
      first_name: "Applicant",
      last_name: "User",
      skip_password_validation: true
    )

    # Create mentorships at different times (ensure they're in the past)
    @old_mentorship = Mentorship.create!(
      mentor: @mentor,
      applicant: @applicant,
      standing: "ended",
      created_at: 7.months.ago
    )

    @recent_mentorship = Mentorship.create!(
      mentor: User.create!(email: "mentor2@example.com", first_name: "M", last_name: "2", skip_password_validation: true),
      applicant: User.create!(email: "applicant2@example.com", first_name: "A", last_name: "2", skip_password_validation: true),
      standing: "active",
      created_at: 2.months.ago
    )

    @new_mentorship = Mentorship.create!(
      mentor: User.create!(email: "mentor3@example.com", first_name: "M", last_name: "3", skip_password_validation: true),
      applicant: User.create!(email: "applicant3@example.com", first_name: "A", last_name: "3", skip_password_validation: true),
      standing: "active",
      created_at: 1.week.ago
    )
  end

  test "backfills email dates based on mentorship creation date" do
    backfiller = EmailDateBackfiller.new
    result = backfiller.backfill_all

    assert result.success?
    assert_equal 3, result.processed_count

    @old_mentorship.reload
    # 7 months ago creation should have all 6 monthly emails "sent"
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
    backfiller = EmailDateBackfiller.new
    backfiller.backfill_all

    @recent_mentorship.reload
    # 2 months ago creation should have only month 1 and 2 emails
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
    backfiller = EmailDateBackfiller.new
    backfiller.backfill_all

    @new_mentorship.reload
    # 1 week ago creation should have no emails yet (less than 1 month)
    assert_nil @new_mentorship.applicant_month_1_email_sent_at
    assert_nil @new_mentorship.mentor_month_1_email_sent_at
  end

  test "skips mentorships that already have email dates" do
    # Pre-set some email dates
    @old_mentorship.update!(
      applicant_month_1_email_sent_at: 5.months.ago,
      mentor_month_1_email_sent_at: 5.months.ago
    )

    backfiller = EmailDateBackfiller.new
    backfiller.backfill_all

    @old_mentorship.reload
    # Should preserve existing dates
    assert_equal 5.months.ago.to_date, @old_mentorship.applicant_month_1_email_sent_at.to_date
    assert_equal 5.months.ago.to_date, @old_mentorship.mentor_month_1_email_sent_at.to_date

    # But still fill in missing ones
    assert_not_nil @old_mentorship.applicant_month_2_email_sent_at
  end

  test "calculates correct email send dates" do
    backfiller = EmailDateBackfiller.new
    backfiller.backfill_all

    @old_mentorship.reload
    created = @old_mentorship.created_at

    # Month 1 email should be ~1 month after creation (allow for DST)
    month1_expected = created + 1.month
    assert_not_nil @old_mentorship.applicant_month_1_email_sent_at
    assert_in_delta month1_expected.to_i, @old_mentorship.applicant_month_1_email_sent_at.to_i, 3.days.to_i

    # Month 2 email should be ~2 months after creation
    month2_expected = created + 2.months
    assert_not_nil @old_mentorship.applicant_month_2_email_sent_at
    assert_in_delta month2_expected.to_i, @old_mentorship.applicant_month_2_email_sent_at.to_i, 3.days.to_i

    # Month 6 email should be ~6 months after creation
    month6_expected = created + 6.months
    assert_not_nil @old_mentorship.applicant_month_6_email_sent_at
    assert_in_delta month6_expected.to_i, @old_mentorship.applicant_month_6_email_sent_at.to_i, 3.days.to_i
  end

  test "provides audit trail of backfilled dates" do
    backfiller = EmailDateBackfiller.new(audit: true)
    result = backfiller.backfill_all

    assert result.success?
    assert result.audit_trail.present?
    assert result.audit_trail.any? { |entry| entry[:mentorship_id] == @old_mentorship.id }

    audit_entry = result.audit_trail.find { |e| e[:mentorship_id] == @old_mentorship.id }
    assert audit_entry[:backfilled_fields].include?("applicant_month_1_email_sent_at")
    assert audit_entry[:backfilled_fields].include?("mentor_month_1_email_sent_at")
  end

  test "handles specific mentorship backfill" do
    backfiller = EmailDateBackfiller.new
    result = backfiller.backfill_mentorship(@old_mentorship)

    assert result[:success]
    assert_equal 12, result[:backfilled_count] # 6 months x 2 (mentor + applicant)

    @old_mentorship.reload
    assert_not_nil @old_mentorship.applicant_month_6_email_sent_at
    assert_not_nil @old_mentorship.mentor_month_6_email_sent_at
  end
end

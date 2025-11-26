require "test_helper"

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
end

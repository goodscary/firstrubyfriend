require "test_helper"

class MentorshipTest < ActiveSupport::TestCase
  fixtures :users

  test "should save with valid mentor and applicant" do
    mentorship = Mentorship.new(mentor: users(:basic), applicant: users(:unverified), standing: "active")
    assert mentorship.save
  end

  test "should not save with same user as mentor and applicant" do
    mentor = users(:mentor)
    mentorship = Mentorship.new(mentor: mentor, applicant: mentor)

    assert_not mentorship.save
  end

  test "should be valid with preset standing enum options" do
    active_mentorship = Mentorship.new(mentor: users(:mentor), applicant: users(:applicant), standing: "active")
    assert_equal "active", active_mentorship.standing
  end

  test "should not be valid with invalid standing enum option" do
    assert_raises(ArgumentError) { Mentorship.new(mentor: users(:mentor), applicant: users(:applicant), standing: "invalid_standing") }
  end

  test "should generate prefixed ID with mnt_ prefix" do
    mentorship = Mentorship.create!(mentor: users(:basic), applicant: users(:unverified), standing: "active")
    assert mentorship.prefix_id.start_with?("mnt_")
    assert mentorship.prefix_id.length > 4
  end

  test "should find mentorship by prefixed ID" do
    mentorship = Mentorship.create!(mentor: users(:basic), applicant: users(:unverified), standing: "active")
    found_mentorship = Mentorship.find_by_prefix_id(mentorship.prefix_id)
    assert_equal mentorship, found_mentorship
  end

  test "should return nil when finding by invalid prefixed ID" do
    result = Mentorship.find_by_prefix_id("mnt_invalid")
    assert_nil result
  end
end

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
end

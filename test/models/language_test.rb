require "test_helper"

class LanguageTest < ActiveSupport::TestCase
  test "should save with valid iso639_alpha3" do
    language = Language.new(iso639_alpha3: "eng")
    assert language.save
  end

  test "should not save without iso639_alpha3" do
    language = Language.new
    assert_not language.save
  end

  test "should not save with duplicate iso639_alpha3" do
    Language.create!(iso639_alpha3: "eng")
    duplicate = Language.new(iso639_alpha3: "eng")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:iso639_alpha3], "has already been taken"
  end
end

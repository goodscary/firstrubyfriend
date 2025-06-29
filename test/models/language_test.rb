require "test_helper"

class LanguageTest < ActiveSupport::TestCase
  test "should save with valid iso639_alpha3" do
    language = Language.new(iso639_alpha3: "rus", iso639_alpha2: "ru", english_name: "Russian", french_name: "russe", local_name: "Русский")
    assert language.save
  end

  test "should not save without iso639_alpha3" do
    language = Language.new
    assert_not language.save
  end

  test "should not save with duplicate iso639_alpha3" do
    Language.create!(iso639_alpha3: "deu", iso639_alpha2: "de", english_name: "German", french_name: "allemand", local_name: "Deutsch")
    duplicate = Language.new(iso639_alpha3: "deu")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:iso639_alpha3], "has already been taken"
  end
end

require "test_helper"

class UserLanguageTest < ActiveSupport::TestCase
  def setup
    @language = languages.english
    @user = users.basic
  end

  test "should save with valid user and language" do
    user_language = UserLanguage.new(user: @user, language: @language)
    assert user_language.save
  end

  test "should not save without user" do
    user_language = UserLanguage.new(language: @language)
    assert_not user_language.save
  end

  test "should not save without language" do
    user_language = UserLanguage.new(user: @user)
    assert_not user_language.save
  end

  test "should not save duplicate user-language pair" do
    UserLanguage.create!(user: @user, language: @language)
    duplicate = UserLanguage.new(user: @user, language: @language)
    assert_not duplicate.save
  end
end

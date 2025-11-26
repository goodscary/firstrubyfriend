require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  class New < RegistrationsControllerTest
    test "renders form" do
      get sign_up_url
      assert_response :success
    end
  end

  class Create < RegistrationsControllerTest
    test "creates user with valid params" do
      assert_difference("User.count") do
        post sign_up_url, params: {email: "lazaronixon@hey.com", password: "Secret1*3*5*", password_confirmation: "Secret1*3*5*"}
      end

      assert_redirected_to root_url
    end

    test "rejects invalid email" do
      assert_no_difference("User.count") do
        post sign_up_url, params: {email: "invalid-email", password: "Secret1*3*5*", password_confirmation: "Secret1*3*5*"}
      end

      assert_response :unprocessable_entity
    end

    test "rejects short password" do
      assert_no_difference("User.count") do
        post sign_up_url, params: {email: "newuser@example.com", password: "short", password_confirmation: "short"}
      end

      assert_response :unprocessable_entity
    end

    test "rejects duplicate email" do
      existing_user = users.basic

      assert_no_difference("User.count") do
        post sign_up_url, params: {email: existing_user.email, password: "Secret1*3*5*", password_confirmation: "Secret1*3*5*"}
      end

      assert_response :unprocessable_entity
    end
  end
end

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create(email: "andy@goodscary.com", password: "Secret1*3*5*")
  end

  test "should get index" do
    sign_in_as @user

    get sessions_url
    assert_response :success
  end

  test "should get new" do
    get sign_in_url
    assert_response :success
  end

  test "should sign in" do
    post sign_in_url, params: {email: @user.email, password: "Secret1*3*5*"}
    assert_redirected_to root_url

    get root_url
    assert_response :success
  end

  test "should sign in with oauth provider" do
    User.stub :from_omniauth, @user do
      get "/auth/:provider/callback"
      assert_redirected_to sign_in_url

      get root_url
      assert_response :success
    end
  end

  test "should not sign in with wrong credentials" do
    post sign_in_url, params: {email: @user.email, password: "SecretWrong1*3"}
    assert_redirected_to sign_in_url(email_hint: @user.email)
    assert_equal "That email or password is incorrect", flash[:alert]
  end

  test "should sign out" do
    sign_in_as @user

    delete session_url(@user.sessions.last)
    assert_redirected_to sessions_url

    follow_redirect!
    assert_redirected_to sign_in_url
  end
end

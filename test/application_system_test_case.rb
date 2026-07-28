require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Pin the browser to the Chrome for Testing build that Selenium Manager
  # downloads alongside the matching chromedriver.
  #
  # Rails' own driver preload (ActionDispatch::SystemTesting::Browser#preload)
  # keeps only the *driver* path Selenium Manager resolves and discards the
  # *browser* path. With no binary set, chromedriver falls back to scanning
  # /Applications and can pick up an unrelated Chrome-family browser whose major
  # version doesn't match, failing with SessionNotCreatedError.
  #
  # NOTE: SeleniumManager is marked @api private, so a selenium-webdriver bump
  # may break this. If it does, drop this block and check whether Rails has
  # started forwarding the browser path itself.
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400] do |options|
    # --avoid-stats skips Selenium Manager's telemetry call to plausible.io,
    # which otherwise sits in driver setup with a 300s network timeout.
    paths = Selenium::WebDriver::SeleniumManager.binary_paths("--browser", "chrome", "--avoid-stats")
    options.binary = paths["browser_path"] if paths["browser_path"].present?
  end

  def sign_in_as(user)
    visit sign_in_url
    fill_in :email, with: user.email
    fill_in :password, with: "Secret1*3*5*"
    click_on "Sign in"

    assert_current_path root_url
    user
  end
end

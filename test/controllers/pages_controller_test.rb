require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get um_bokatidindi" do
    get pages_um_bokatidindi_url
    assert_response :success
  end

  test "should get privacy_policy" do
    get pages_privacy_policy_url
    assert_response :success
  end
end

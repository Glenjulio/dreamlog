require "test_helper"

class TranscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get transcriptions_show_url
    assert_response :success
  end

  test "should get edit" do
    get transcriptions_edit_url
    assert_response :success
  end
end

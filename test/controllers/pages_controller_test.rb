require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get pages_home_url
    assert_response :success
  end

  test "should get recording" do
    get pages_recording_url
    assert_response :success
  end

  test "should get recording_done" do
    get pages_recording_done_url
    assert_response :success
  end

  test "should get save" do
    get pages_save_url
    assert_response :success
  end

  test "should get transcription" do
    get pages_transcription_url
    assert_response :success
  end

  test "should get analyze" do
    get pages_analyze_url
    assert_response :success
  end

  test "should get past_recording" do
    get pages_past_recording_url
    assert_response :success
  end
end

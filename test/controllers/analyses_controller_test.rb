require "test_helper"

class AnalysesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get analyses_index_url
    assert_response :success
  end

  test "should get show" do
    get analyses_show_url
    assert_response :success
  end
end

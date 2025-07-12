require "test_helper"

class DreamsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get dreams_index_url
    assert_response :success
  end

  test "should get new" do
    get dreams_new_url
    assert_response :success
  end

  test "should get edit" do
    get dreams_edit_url
    assert_response :success
  end

  test "should get show" do
    get dreams_show_url
    assert_response :success
  end
end

require "test_helper"

class PersonalitiesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get personalities_new_url
    assert_response :success
  end

  test "should get create" do
    get personalities_create_url
    assert_response :success
  end

  test "should get show" do
    get personalities_show_url
    assert_response :success
  end

  test "should get edit" do
    get personalities_edit_url
    assert_response :success
  end

  test "should get update" do
    get personalities_update_url
    assert_response :success
  end

  test "should get index" do
    get personalities_index_url
    assert_response :success
  end
end

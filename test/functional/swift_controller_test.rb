require 'test_helper'

class SwiftControllerTest < ActionController::TestCase
  test "should get test_swift" do
    get :test_swift
    assert_response :success
  end

  test "should get read_environment" do
    get :read_environment
    assert_response :success
  end

end

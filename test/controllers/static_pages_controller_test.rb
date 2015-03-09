require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test "should get contribute" do
    get :contribute
    assert_response :success
  end

end

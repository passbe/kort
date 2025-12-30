require "test_helper"

class ExecutionsControllerTest < ActionDispatch::IntegrationTest

  test "should get index" do
    get executions_url
    assert_response :success
  end

  test "should show execution" do
    get execution_url(create(:execution))
    assert_response :success
  end

end

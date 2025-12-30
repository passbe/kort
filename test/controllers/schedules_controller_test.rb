require "test_helper"

class SchedulesControllerTest < ActionDispatch::IntegrationTest

  test "should post validate valid" do
    attributes = {
      expression: "test",
      grace: "1m",
      target_type: "Probe",
      target_id: nil
    }
    post validate_schedules_url(format: :turbo_stream), params: { schedule: attributes }
    assert_response :success
  end

  test "should post create valid" do
    attributes = {
      expression: "test",
      grace: "1m",
      target_type: "Probe",
      target_id: 99
    }
    post schedules_url(format: :turbo_stream), params: { schedule: attributes }
    assert_response :success
  end

end

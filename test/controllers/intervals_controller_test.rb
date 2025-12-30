require "test_helper"

class IntervalsControllerTest < ActionDispatch::IntegrationTest

  test "should get index" do
    create(:interval)
    get intervals_url
    assert_response :success
  end

  test "should get show" do
    interval = create(:interval)
    get interval_url(interval)
    assert_response :success
  end

  test "should get new" do
    get new_interval_url
    assert_response :success
  end

  test "should create interval" do
    interval = build(:interval)
    attributes = interval.attributes.except(
      :id.to_s,
      :created_at.to_s,
      :updated_at.to_s
    )
    # Schedule
    attributes["schedules_attributes"] = { "0": { "expression": "Mon" } }
    assert_difference("Interval.count") do
      assert_difference("Schedule.count") do
        post intervals_url, params: { interval: attributes }
      end
    end
    assert_redirected_to interval_url(Interval.first)
  end

  test "should get edit" do
    interval = create(:interval)
    get edit_interval_url(interval)
    assert_response :success
  end

  test "should update interval" do
    interval = create(:interval)
    schedule = create(:schedule, target: interval)
    new_schedule_expression = "Fri"
    attributes = {
      name: "Tests interval New",
      description: "Hello!",
      tag_list: "alpha, beta, charlie",
      schedules_attributes: {
        "0": {
          "id": schedule.id,
          "_destroy": "1"
        },
        "1": {
          "id": "",
          "expression": new_schedule_expression,
          "_destroy": ""
        }
      }
    }
    patch interval_url(interval), params: { interval: attributes }
    assert_redirected_to interval_url(interval)
    assert_equal interval, Interval.first
    assert_not_equal schedule.id, Interval.first.schedules.first.id
    assert_equal new_schedule_expression, Interval.first.schedules.first.expression
  end

  test "should get confirm" do
    interval = create(:interval)
    get confirm_interval_url(interval)
    assert_response :success
  end

  test "should destroy interval" do
    interval = create(:interval)
    assert_difference("Interval.count", -1) do
      delete interval_url(interval)
    end
    assert_redirected_to intervals_url
  end

  test "should get signal" do
    interval = create(:interval)
    execution = create(:execution, target: interval)
    Schedule.any_instance.expects(:reset!).returns(true)
    get signal_interval_url(interval, status: Execution::Status::SKIPPED, message: "SPECS")
    assert_response :success
    execution.reload
    assert execution.skipped?
    assert_equal "SPECS", execution.message
  end

  test "should get signal without execution" do
    interval = create(:interval)
    get signal_interval_url(interval)
    assert_response :bad_request
  end

  test "should get signal with error" do
    interval = create(:interval)
    execution = create(:execution, target: interval)
    get signal_interval_url(interval, status: "WRONG")
    assert_response :bad_request
    execution.reload
    assert execution.pending?
  end

  test "should get start" do
    interval = create(:interval)
    execution = create(:execution, target: interval)
    get start_interval_url(interval)
    assert_response :success
    execution.reload
    refute_nil execution.started_at
    assert execution.started?
  end

  test "should get start without execution" do
    interval = create(:interval)
    get start_interval_url(interval)
    assert_response :bad_request
  end

  test "should post log" do
    interval = create(:interval)
    execution = create(:execution, target: interval)
    post log_interval_url(interval), env: { 'RAW_POST_DATA': "line 1\nline 2" }, as: :plain
    assert_response :no_content
  end

  test "should post log without execution" do
    interval = create(:interval)
    post log_interval_url(interval), env: { 'RAW_POST_DATA': "line 1\nline 2" }, as: :plain
    assert_response :bad_request
  end

end

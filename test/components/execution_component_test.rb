require "test_helper"

class ExecutionComponentTest < ViewComponent::TestCase

  include Rails.application.routes.url_helpers

  def render(execution, variant: :detailed)
    render_inline(ExecutionComponent.new(execution: execution, variant: variant))
    assert_component_rendered
  end

  [Execution::Status::PENDING, Execution::Status::STARTED].each do |status|
    test "subscribes to broadcasts when #{status}" do
      execution = create(:execution, status: status)
      render(execution)
      assert_xpath "//td/turbo-cable-stream-source[@channel=\"Turbo::StreamsChannel\"]"
    end
  end

  test "has a tags for each td" do
    execution = create(:execution)
    render(execution)
    assert_xpath "//td/a", count: 5
  end

  test "has execution :counter" do
    execution = create(:execution, counter: 128885)
    render(execution)
    assert_xpath "//td/a", text: "128,885"
  end

  test "has :message" do
    message = "This is a status message, yippie!"
    render(create(:execution, message: message))
    assert_xpath "//td/a", text: message
  end

  test "has nil :message" do
    render(create(:execution, message: nil))
    assert_xpath "//td/a", text: I18n.t("execution.no_message")
  end

  test "has no elapsed" do
    execution = create(
      :execution,
      started_at: nil
    )
    render(execution)
    assert_xpath "//td/a", text: "-"
  end

  test "has elapsed" do
    execution = create(
      :execution,
      started_at: Time.local(2000, 1, 2, 0, 0, 59),
      finished_at: Time.local(2000, 1, 2, 18, 12, 59)
    )
    render(execution)
    assert_xpath "//td/a", text: "18h 12m 0s"
  end

  test "has elapsed with timer" do
    execution = create(
      :execution,
      status: Execution::Status::STARTED,
      started_at: Time.local(2000, 1, 2, 0, 0, 59),
      finished_at: nil
    )
    render(execution)
    assert_xpath "//td/a[@data-controller=\"timer\" and @data-timer-time-value=\"#{execution.started_at.to_i}\"]"
  end

  test "has :created_at" do
    execution = create(:execution)
    render(execution)
    assert_xpath "//td/a", text: execution.created_at.strftime("%Y-%m-%d %H:%M:%S")
  end

  test "has :started_at" do
    execution = create(:execution, target: create(:interval), started_at: Time.now - 5.minutes)
    render(execution)
    assert_xpath "//td/a", text: execution.started_at.strftime("%Y-%m-%d %H:%M:%S")
  end

  test "has :started_at with :finished_at set" do
    execution = create(:execution, target: create(:interval), started_at: Time.now - 5.minutes, finished_at: Time.now - 4.minutes)
    render(execution)
    assert_xpath "//td/a", text: execution.started_at.strftime("%Y-%m-%d %H:%M:%S")
  end

  test "has :finished_at without :started_at set" do
    execution = create(:execution, target: create(:interval), started_at: nil, finished_at: Time.now - 4.minutes)
    render(execution)
    assert_xpath "//td/a", text: execution.finished_at.strftime("%Y-%m-%d %H:%M:%S")
  end

  Execution::STATUSES.each do |status|
    test "has :status #{status}" do
      render(create(:execution, status: status))
      assert_xpath "//td/a", text: I18n.t("status.#{status}")
    end
  end

  test "variant :summary has target link" do
    target = create(:probe)
    execution = create(:execution, target: target)
    render(execution, variant: :summary)
    assert_xpath "//td/a[@href=\"#{probe_path(target)}\"]", text: target.name
  end

end

require "test_helper"

class ExecutionLogsComponentTest < ViewComponent::TestCase

  include Rails.application.routes.url_helpers

  def render(execution)
    render_inline(ExecutionLogsComponent.new(execution))
    assert_component_rendered
  end

  test "has title" do
    ExecutionLogsComponent.any_instance.expects(:log_exist?).twice.returns(true)
    ExecutionLogsComponent.any_instance.expects(:logs).returns([])
    execution = build(:execution, id: 99)
    execution.stubs(:log_file).returns(Pathname.new("/tmp/rails-testing.txt"))
    render(execution)
    assert_xpath "//h1", text: I18n.t("execution.logs")
  end

  test "has log file download" do
    ExecutionLogsComponent.any_instance.expects(:log_exist?).twice.returns(true)
    ExecutionLogsComponent.any_instance.expects(:logs).returns([])
    execution = build(:execution, id: 99)
    execution.stubs(:log_file).returns(Pathname.new("/tmp/rails-testing.txt"))
    render(execution)
    assert_xpath "//a[@href=\"#{download_log_execution_path(execution)}\"]", text: execution.log_file.basename
    assert_text I18n.t("activerecord.attributes.execution.log_identifier")
  end

  test "is pending but no logs" do
    ExecutionLogsComponent.any_instance.expects(:log_exist?).twice.returns(true)
    ExecutionLogsComponent.any_instance.expects(:logs).returns([])
    execution = build(:execution, status: Execution::Status::PENDING, id: 99)
    execution.stubs(:log_file).returns(Pathname.new("/tmp/rails-testing.txt"))
    render(execution)
    refute_text I18n.t("execution.no_log")
  end

  test "no log file" do
    ExecutionLogsComponent.any_instance.expects(:log_exist?).twice.returns(false)
    execution = build(:execution, status: Execution::Status::SKIPPED, id: 99)
    render(execution)
    assert_text I18n.t("execution.no_log")
  end

  test "has log line link with reference" do
    ExecutionLogsComponent.any_instance.expects(:log_exist?).twice.returns(true)
    File.expects(:foreach).returns(["[TIME][INFO] Message"])
    execution = build(:execution, id: 99)
    execution.stubs(:log_file).returns(Pathname.new("/tmp/rails-testing.txt"))
    render execution
    assert_xpath "//a[@href=\"#line-1\"]", text: 1
    assert_xpath "//div[@id=\"line-1\"]"
  end

  test "has message" do
    ExecutionLogsComponent.any_instance.expects(:log_exist?).twice.returns(true)
    message = "This is a testing error|warn something message"
    File.expects(:foreach).returns(["[TIME][INFO] #{message}"])
    execution = build(:execution, id: 99)
    execution.stubs(:log_file).returns(Pathname.new("/tmp/rails-testing.txt"))
    render execution
    assert_text message
  end

  ["ANY", "WARN"].each do |level|
    test "highlights level #{level}" do
      ExecutionLogsComponent.any_instance.expects(:log_exist?).twice.returns(true)
      File.expects(:foreach).returns(["[TIME][#{level}] Message"])
      execution = build(:execution, id: 99)
      execution.stubs(:log_file).returns(Pathname.new("/tmp/rails-testing.txt"))
      render execution
      assert_xpath "//div[contains(@class, \"bg-orange-\")]"
    end
  end

  ["FATAL", "ERROR"].each do |level|
    test "highlights level #{level}" do
      ExecutionLogsComponent.any_instance.expects(:log_exist?).twice.returns(true)
      File.expects(:foreach).returns(["[TIME][#{level}] Message"])
      execution = build(:execution, id: 99)
      execution.stubs(:log_file).returns(Pathname.new("/tmp/rails-testing.txt"))
      render execution
      assert_xpath "//div[contains(@class, \"bg-red-\")]"
    end
  end

  test "has timestamp" do
    ExecutionLogsComponent.any_instance.expects(:log_exist?).twice.returns(true)
    timestamp = "This is a fake timestamp - we don't parse them we just echo"
    File.expects(:foreach).returns(["[#{timestamp}][INFO] Message"])
    execution = build(:execution, id: 99)
    execution.stubs(:log_file).returns(Pathname.new("/tmp/rails-testing.txt"))
    render execution
    assert_text timestamp
  end

end

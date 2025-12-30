require "test_helper"

class ScheduleFormComponentTest < ViewComponent::TestCase

  include Rails.application.routes.url_helpers

  def render(schedule:, without_grace: false)
    render_inline(ScheduleFormComponent.new(schedule: schedule, without_grace: without_grace))
    assert_component_rendered
  end

  ["probe_schedules_form_validate", "probe_schedules_form_create"].each do |frame|
    test "has #{frame} turbo frame" do
      render(schedule: build(:schedule, target_type: "Probe"))
      assert_xpath "//turbo-frame[@id=\"#{frame}\"]"
    end
  end

  test "has form (validate)" do
    render(schedule: build(:schedule))
    assert_xpath "//form[@action=\"#{validate_schedules_path}\" and @method=\"post\" and @data-schedule-target=\"validateForm\"]"
  end

  [:target_type, :target_id].each do |field|
    test "has validate form :#{field} hidden field" do
      render(schedule: build(:schedule))
      assert_xpath "//form[@action=\"#{validate_schedules_path}\"]/input[@type=\"hidden\" and @id=\"schedule_#{field}\"]", visible: false
    end
  end

  test "has :expression input" do
    render(schedule: build(:schedule))
    assert_xpath "//input[@id=\"schedule_expression\" and contains(@data-action, \"schedule#validate\")]"
  end

  test "has :grace input" do
    render(schedule: build(:schedule))
    assert_xpath "//input[@id=\"schedule_grace\" and contains(@data-action, \"schedule#validate\")]"
  end

  test "refute :grace input when without_grace = true" do
    render(schedule: build(:schedule), without_grace: true)
    refute_xpath "//input[@id=\"schedule_grace\"]"
  end

  test "refute :expression add link on blank" do
    render(schedule: build(:schedule, expression: ""), without_grace: true)
    refute_xpath "//a[@data-action=\"schedule#submit:stop\" and @disabled=\"disabled\"]", text: I18n.t("button.add")
  end

  test "refute :expression add link on invalid" do
    schedule = build(:schedule)
    render(schedule: schedule, without_grace: true)
    refute_xpath "//a[@data-action=\"schedule#submit:stop\" and @disabled=\"disabled\"]", text: I18n.t("button.add")
  end

  test "has :expression add link on valid" do
    render(schedule: build(:schedule), without_grace: true)
    assert_xpath "//a[@data-action=\"schedule#submit:stop\" and not(@disabled=\"disabled\")]", text: I18n.t("button.add")
  end

  test "has :expression message if blank" do
    render(schedule: build(:schedule, expression: ""), without_grace: true)
    assert_text I18n.t("schedule.expression.prompt")
  end

  test "has :expression error" do
    schedule = build(:schedule, expression: "@@@@")
    schedule.valid?
    render(schedule: schedule, without_grace: true)
    assert_text schedule.errors.where(:expression).first.full_message
  end

  test "has :next_execution_at error" do
    schedule = build(:schedule)
    schedule.next_execution_at = nil
    schedule.valid?
    render(schedule: schedule, without_grace: true)
    assert_text schedule.errors.where(:next_execution_at).first.full_message
  end

  test "has :expression message if valid" do
    schedule = build(:schedule)
    render(schedule: schedule)
    assert_text I18n.t("schedule.expression.valid", time: schedule.next_execution_at)
  end

  test "refute :grace add link on blank" do
    render(schedule: build(:schedule, grace: ""))
    refute_xpath "//a[@data-action=\"schedule#submit:stop\" and @disabled=\"disabled\"]", text: I18n.t("button.add")
  end

  test "refute :grace add link on invalid" do
    schedule = build(:schedule, grace: "aa")
    render(schedule: schedule)
    refute_xpath "//a[@data-action=\"schedule#submit:stop\" and @disabled=\"disabled\"]", text: I18n.t("button.add")
  end

  test "has :grace add link on valid" do
    schedule = build(:schedule)
    schedule.grace = "1m"
    render(schedule: schedule)
    assert_xpath "//a[@data-action=\"schedule#submit:stop\" and not(@disabled=\"disabled\")]", text: I18n.t("button.add")
  end

  test "has :grace message if blank" do
    render(schedule: build(:schedule, grace: ""))
    assert_text I18n.t("schedule.grace.prompt")
  end

  test "has :grace error" do
    schedule = build(:schedule, grace: "@@@@")
    schedule.valid?
    render(schedule: schedule)
    assert_text schedule.errors.where(:grace).first.full_message
  end

  test "has :grace_expires_at error" do
    schedule = build(:schedule, grace: "1m")
    schedule.grace_expires_at = nil
    schedule.valid?
    render(schedule: schedule)
    assert_text schedule.errors.where(:grace_expires_at).first.full_message
  end

  test "has :grace message if valid" do
    schedule = build(:schedule)
    schedule.grace = "1m"
    render(schedule: schedule)
    assert_text I18n.t("schedule.grace.valid", time: schedule.grace_expires_at)
  end

  test "has form (create)" do
    render(schedule: build(:schedule))
    assert_xpath "//form[@action=\"#{schedules_path}\" and @method=\"post\" and @data-schedule-target=\"createForm\"]"
  end

  [:target_type, :target_id, :expression, :grace].each do |field|
    test "has create form :#{field} hidden field" do
      render(schedule: build(:schedule))
      assert_xpath "//form[@action=\"#{schedules_path}\"]/input[@type=\"hidden\" and @id=\"schedule_#{field}\"]", visible: false
    end
  end
end

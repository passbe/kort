require "test_helper"

class ScheduleFormFieldComponentTest < ViewComponent::TestCase

  include Rails.application.routes.url_helpers

  def render(schedule:, without_grace: false)
    render_inline(ScheduleFormFieldComponent.new(schedule: schedule, schedule_counter: 99, without_grace: without_grace))
    assert_component_rendered
  end

  test "has container" do
    render(schedule: build(:schedule))
    assert_xpath "//div[@data-schedule-target=\"schedule\"]"
  end

  test "has :expression" do
    schedule = build(:schedule)
    render(schedule: schedule)
    assert_text schedule.expression
  end

  test "has :grace" do
    schedule = build(:schedule, grace: "1m")
    render(schedule: schedule)
    assert_text schedule.grace
  end

  test "refute :grace when without_grace = true" do
    schedule = build(:schedule, grace: "1m")
    render(schedule: schedule, without_grace: true)
    refute_text schedule.grace
  end

  test "has :next_execution_at" do
    schedule = build(:schedule)
    render(schedule: schedule)
    assert_text schedule.next_execution_at
  end

  test "has :grace_expires_at" do
    schedule = build(:schedule, grace_expires_at: Time.now - 4.months)
    render(schedule: schedule)
    assert_text schedule.grace_expires_at
  end

  test "refute :grace_expires_at when without_grace = true" do
    schedule = build(:schedule, grace_expires_at: Time.now - 4.months)
    render(schedule: schedule, without_grace: true)
    refute_text schedule.grace_expires_at
  end

  test "has remove link" do
    render(schedule: build(:schedule))
    assert_xpath "//a[@data-action=\"schedule#remove:prevent\"]", text: I18n.t("button.remove")
  end

  [:id, :expression, :grace, :_destroy].each do |field|
    test "has #{field} hidden field" do
      render(schedule: build(:schedule))
      assert_xpath "//input[@type=\"hidden\" and @form=\"probe_form\" and @id=\"probe_schedules_attributes_99_#{field}\" and @name=\"probe[schedules_attributes][99][#{field}]\"]", visible: false
    end
  end

  test "hidden container - destruction = true" do
    schedule = build(:schedule)
    schedule.mark_for_destruction
    render(schedule: schedule)
    assert_xpath "//div[@data-schedule-target=\"schedule\" and contains(@class, \"hidden\")]"
  end

  test "_destroy true - destruction = true" do
    schedule = build(:schedule)
    schedule.mark_for_destruction
    render(schedule: schedule)
    assert_xpath "//input[@type=\"hidden\" and @form=\"probe_form\" and @id=\"probe_schedules_attributes_99__destroy\" and @name=\"probe[schedules_attributes][99][_destroy]\" and @value=\"true\"]", visible: false
  end

end

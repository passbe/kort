require "test_helper"

class IntervalFormComponentTest < ViewComponent::TestCase

  include Rails.application.routes.url_helpers

  def render(interval:)
    render_inline(IntervalFormComponent.new(interval: interval))
    assert_component_rendered
  end

  test "has form (new)" do
    render(interval: build(:interval))
    assert_xpath "//form[@action=\"#{intervals_path}\" and @method=\"post\" and @id=\"interval_form\"]"
  end

  test "has form (exisiting)" do
    interval = create(:interval)
    render(interval: interval)
    assert_xpath "//form[@action=\"#{interval_path(interval)}\" and @method=\"post\" and @id=\"interval_form\"]"
  end

  test "has model base errors" do
    msg = "Test Error Message Here!"
    interval = build(:interval)
    interval.errors.add(:base, msg)
    render(interval: interval)
    assert_xpath "//div", text: msg
  end

  [:enabled, :name, :description, :tag_list, :evaluator].each do |field|
    test "has :#{field} label" do
      render(interval: build(:interval))
      assert_xpath "//label[@for=\"interval_#{field}\"]", text: Interval.human_attribute_name(field)
    end
  end

  test "has :enabled input" do
    render(interval: build(:interval))
    assert_xpath "//input[@name=\"interval[enabled]\" and @type=\"checkbox\"]"
  end

  [:name, :tag_list].each do |field|
    test "has :#{field} input" do
      render(interval: build(:interval))
      assert_xpath "//input[@name=\"interval[#{field}]\"]"
    end
  end

  [:description, :evaluator].each do |field|
    test "has :#{field} textarea" do
      render(interval: build(:interval))
      assert_xpath "//textarea[@name=\"interval[#{field}]\"]"
    end
  end

  test "has :evaluator warning text" do
    render(interval: build(:interval))
    assert_text I18n.t("evaluator.warning")
  end

  ["interval_schedules_form_list"].each do |frame|
    test "has #{frame} turbo frame" do
      render(interval: build(:interval))
      assert_xpath "//turbo-frame[@id=\"#{frame}\"]"
    end
  end
end

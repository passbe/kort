require "test_helper"

class IntervalComponentTest < ViewComponent::TestCase

  include Rails.application.routes.url_helpers

  def render(interval:)
    render_inline(IntervalComponent.new(interval: interval))
    assert_component_rendered
  end

  test "has a tags for each td" do
    interval = create(:interval)
    render(interval: interval)
    assert_xpath "//td/a", count: 4
  end

  test "has :enabled true" do
    interval = create(:interval, enabled: true)
    render(interval: interval)
    assert_xpath "//td/a", text: I18n.t("status.enabled")
  end

  test "has :enabled false" do
    interval = create(:interval, enabled: false)
    render(interval: interval)
    assert_xpath "//td/a", text: I18n.t("status.disabled")
  end

  test "has :name" do
    name = "Juice Squeeze"
    interval = create(:interval, name: name)
    render(interval: interval)
    assert_xpath "//td/a", text: name
  end

  test "has :tag_list" do
    interval = create(:interval, tag_list: "alpha, beta, charlie")
    render(interval: interval)
    assert_xpath "//td/a", text: interval.tag_list.join(", ")
  end

  test "has :schedules_count" do
    interval = create(:interval)
    create(:schedule, target: interval, expression: "Mon")
    create(:schedule, target: interval, expression: "Tue")
    create(:schedule, target: interval, expression: "Wed")
    create(:schedule, target: interval, expression: "Thur")
    render(interval: interval)
    assert_xpath "//tr/td", text: 4
  end

end

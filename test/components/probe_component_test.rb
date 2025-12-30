require "test_helper"

class ProbeComponentTest < ViewComponent::TestCase

  include Rails.application.routes.url_helpers

  def render(probe:)
    render_inline(ProbeComponent.new(probe: probe))
    assert_component_rendered
  end

  test "has a tags for each td" do
    probe = create(:probe_dns)
    render(probe: probe)
    assert_xpath "//td/a", count: 5
  end

  test "has :enabled true" do
    probe = create(:probe_dns, enabled: true)
    render(probe: probe)
    assert_xpath "//td/a", text: I18n.t("status.enabled")
  end

  test "has :enabled false" do
    probe = create(:probe_dns, enabled: false)
    render(probe: probe)
    assert_xpath "//td/a", text: I18n.t("status.disabled")
  end

  test "has :name" do
    name = "Juice Squeeze"
    probe = create(:probe_dns, name: name)
    render(probe: probe)
    assert_xpath "//td/a", text: name
  end

  test "has :type" do
    probe = create(:probe_dns)
    render(probe: probe)
    assert_xpath "//td/a", text: probe.model_name.human
  end

  test "has :tag_list" do
    probe = create(:probe_dns, tag_list: "alpha, beta, charlie")
    render(probe: probe)
    assert_xpath "//td/a", text: probe.tag_list.join(", ")
  end

  test "has :schedules_count" do
    probe = create(:probe)
    create(:schedule, target: probe, expression: "Mon")
    create(:schedule, target: probe, expression: "Tue")
    create(:schedule, target: probe, expression: "Wed")
    create(:schedule, target: probe, expression: "Thur")
    render(probe: probe)
    assert_xpath "//tr/td", text: 4
  end

end

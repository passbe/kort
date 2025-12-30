require "test_helper"

class ProbeFormComponentTest < ViewComponent::TestCase

  include Rails.application.routes.url_helpers

  def render(probe:)
    render_inline(ProbeFormComponent.new(probe: probe))
    assert_component_rendered
  end

  test "has form (new)" do
    render(probe: build(:probe, type: nil))
    assert_xpath "//form[@action=\"#{probes_path}\" and @method=\"post\" and @id=\"probe_form\"]"
  end

  test "has form (exisiting)" do
    probe = create(:probe_dns)
    render(probe: probe)
    assert_xpath "//form[@action=\"#{probe_path(probe)}\" and @method=\"post\" and @id=\"probe_form\"]"
  end

  test "has model base errors" do
    msg = "Test Error Message Here!"
    probe = build(:probe, type: nil)
    probe.errors.add(:base, msg)
    render(probe: probe)
    assert_xpath "//div", text: msg
  end

  [:enabled, :name, :description, :type, :tag_list, :evaluator].each do |field|
    test "has :#{field} label" do
      render(probe: build(:probe, type: nil))
      assert_xpath "//label[@for=\"probe_#{field}\"]", text: Probe.human_attribute_name(field)
    end
  end

  test "has :enabled input" do
    render(probe: build(:probe, type: nil))
    assert_xpath "//input[@name=\"probe[enabled]\" and @type=\"checkbox\"]"
  end

  [:name, :tag_list].each do |field|
    test "has :#{field} input" do
      render(probe: build(:probe, type: nil))
      assert_xpath "//input[@name=\"probe[#{field}]\"]"
    end
  end

  [:description, :evaluator].each do |field|
    test "has :#{field} textarea" do
      render(probe: build(:probe, type: nil))
      assert_xpath "//textarea[@name=\"probe[#{field}]\"]"
    end
  end

  test "has :evaluator warning text" do
    render(probe: build(:probe, type: nil))
    assert_text I18n.t("evaluator.warning")
  end

  [:type].each do |field|
    test "has :#{field} select" do
      render(probe: build(:probe, type: nil))
      assert_xpath "//select[@name=\"probe[#{field}]\"]"
    end
  end

  Probe.subclasses.each do |kclass|
    test "has :type option for #{kclass}" do
      render(probe: build(:probe, type: nil))
      assert_xpath "//select/option[@value=\"#{kclass}\"]"
    end
  end

  ["probe_type_fields", "probe_schedules_form_list"].each do |frame|
    test "has #{frame} turbo frame" do
      render(probe: build(:probe, type: nil))
      assert_xpath "//turbo-frame[@id=\"#{frame}\"]"
    end
  end
end

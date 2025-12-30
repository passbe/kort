require "test_helper"

class Probes::PortFormComponentTest < ViewComponent::TestCase

  def render(probe:)
    render_inline(Probes::PortFormComponent.new(probe: probe))
    assert_component_rendered
  end

  [:host, :port, :timeout].each do |field|
    test "has :#{field} label" do
      render(probe: build(:probe_port))
      assert_xpath "//label[@for=\"probe_#{field}\"]", text: Probes::Dns.human_attribute_name(field)
    end
  end

  [:host, :port, :timeout].each do |field|
    test "has :#{field} input" do
      render(probe: build(:probe_port))
      assert_xpath "//input[@name=\"probe[#{field}]\"]"
    end
  end

end

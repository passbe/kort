require "test_helper"

class Probes::DockerFormComponentTest < ViewComponent::TestCase

  def render(probe:)
    render_inline(Probes::DockerFormComponent.new(probe: probe))
    assert_component_rendered
  end

  [:path, :reference].each do |field|
    test "has :#{field} label" do
      render(probe: build(:probe_docker))
      assert_xpath "//label[@for=\"probe_#{field}\"]", text: Probes::Docker.human_attribute_name(field)
    end
  end

  [:path, :reference].each do |field|
    test "has :#{field} input" do
      render(probe: build(:probe_docker))
      assert_xpath "//input[@name=\"probe[#{field}]\"]"
    end
  end

end

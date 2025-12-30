require "test_helper"

class Probes::HttpFormComponentTest < ViewComponent::TestCase

  def render(probe:)
    render_inline(Probes::HttpFormComponent.new(probe: probe))
    assert_component_rendered
  end

  [:url, :method, :timeout, :verify_ssl, :follow_redirect, :headers, :body].each do |field|
    test "has :#{field} label" do
      render(probe: build(:probe_http))
      assert_xpath "//label[@for=\"probe_#{field}\"]", text: Probes::Http.human_attribute_name(field)
    end
  end

  [:url, :timeout].each do |field|
    test "has :#{field} input" do
      render(probe: build(:probe_http))
      assert_xpath "//input[@name=\"probe[#{field}]\"]"
    end
  end

  [:headers, :body].each do |field|
    test "has :#{field} text area" do
      render(probe: build(:probe_http))
      assert_xpath "//textarea[@name=\"probe[#{field}]\"]"
    end
  end

  [:method].each do |field|
    test "has :#{field} select" do
      render(probe: build(:probe_http))
      assert_xpath "//select[@name=\"probe[#{field}]\"]"
    end
  end

  [:verify_ssl, :follow_redirect].each do |field|
    test "has :#{field} checkbox" do
      render(probe: build(:probe_http))
      assert_xpath "//input[@type=\"checkbox\" and @name=\"probe[#{field}]\"]"
    end
  end

end

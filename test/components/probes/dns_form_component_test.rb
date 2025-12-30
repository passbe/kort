require "test_helper"

class Probes::DnsFormComponentTest < ViewComponent::TestCase

  def render(probe:)
    render_inline(Probes::DnsFormComponent.new(probe: probe))
    assert_component_rendered
  end

  [:host, :record, :nameserver, :port, :protocol].each do |field|
    test "has :#{field} label" do
      render(probe: build(:probe_dns))
      assert_xpath "//label[@for=\"probe_#{field}\"]", text: Probes::Dns.human_attribute_name(field)
    end
  end

  [:host, :nameserver, :port].each do |field|
    test "has :#{field} input" do
      render(probe: build(:probe_dns))
      assert_xpath "//input[@name=\"probe[#{field}]\"]"
    end
  end

  [:record].each do |field|
    test "has :#{field} select" do
      render(probe: build(:probe_dns))
      assert_xpath "//select[@name=\"probe[#{field}]\"]"
    end
  end

  Probes::Dns::PROTOCOLS.each do |protocol|
    test "has :protocol #{protocol} radio + label" do
      render(probe: build(:probe_dns))
      assert_xpath "//input[@type=\"radio\" and @name=\"probe[protocol]\" and @value=\"#{protocol}\"]"
      assert_xpath "//label[@for=\"probe_protocol_#{protocol.downcase}\"]"
    end
  end

end

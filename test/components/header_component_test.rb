require "test_helper"

class HeaderComponentTest < ViewComponent::TestCase

  def render(title:, attributes: {}, statistics: {}, status: nil, status_css: nil)
    render_inline(HeaderComponent.new(
      title: title,
      attributes: attributes,
      statistics: statistics,
      status: status,
      status_css: status_css
    ))
    assert_component_rendered
  end

  test "has header" do
    render(title: "")
    assert_xpath "/html/body/header"
  end

  test "has :title" do
    title = "Test Header Spec Title"
    render(title: title)
    assert_xpath "//div", text: title
  end

  test "has attribute" do
    key, value = "Attribute Name", "This is a value field"
    render(title: "", attributes: {
      key => value
    })
    assert_xpath "//div", text: "#{key}: #{value}", normalize_ws: true
  end

  test "has attribute without value" do
    key, value = "Attribute Name", "This is a value field"
    render(title: "", attributes: {
      key => nil
    })
    assert_xpath "//div", text: "#{key}"
  end

  test "has statistic" do
    key, value = "Statistic Name", 999
    render(title: "", statistics: {
      key => value
    })
    assert_xpath "//dt", text: key
    assert_xpath "//dd", text: value
  end

  test "has statistic with data" do
    key, value = "Statistic Name", "abc"
    render(title: "", statistics: {
      key => {
        value: value,
        data: {
          controller: "test"
        }
      }
    })
    assert_xpath "//dt", text: key
    assert_xpath "//dd[@data-controller=\"test\"]", text: value
  end

  test "has status" do
    status, css = "ENABLED!!", "bg-something-8000"
    render(title: "", status: status, status_css: css)
    assert_xpath "//div[contains(@class, \"#{css}\")]", text: status
  end
end

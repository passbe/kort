require "test_helper"

class TableComponentTest < ViewComponent::TestCase

  def render(fields)
    render_inline(TableComponent.new(fields))
    assert_component_rendered
  end

  test "empty :fields" do
    render_inline(TableComponent.new)
    refute_component_rendered
  end

  test "has table" do
    render(["one"])
    assert_xpath "//table"
    assert_xpath "//table/thead"
    assert_xpath "//table/tbody"
  end

  test "has :fields simple" do
    fields = ["one", "two", "three"]
    render(fields)
    fields.each do |field|
      assert_xpath "//table/thead/tr/th[contains(@class, \"text-center\")]", text: field
    end
  end

  test "has :fields complex" do
    fields = [
      "one",
      { text: "two", align: :left },
      { text: "three", align: :right }
    ]
    render(fields)
    fields.each do |field|
      text = field.is_a?(Hash) ? field.dig(:text) : field
      css = field.is_a?(Hash) ? "text-#{field.dig(:align)}" : "text-center"
      assert_xpath "//table/thead/tr/th[contains(@class, \"#{css}\")]", text: text
    end
  end

end

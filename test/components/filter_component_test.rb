require "test_helper"

class FilterComponentTest < ViewComponent::TestCase

  def render(mode: nil, date: nil, reset_path: nil, pagy:)
    render_inline(FilterComponent.new(
      mode: mode,
      date: date,
      reset_path: reset_path,
      pagy: pagy
    ))
    assert_component_rendered
  end

  def pagy(from: 1, to: 10, count: 499)
    obj = mock()
    obj.stubs(:from).returns(from)
    obj.stubs(:to).returns(to)
    obj.stubs(:count).returns(count)
    obj
  end

  test "has pagination info" do
    p = pagy
    render(pagy: p)
    assert_text "#{I18n.t("pagination.display")} #{p.from} - #{p.to} #{I18n.t("pagination.of")} #{p.count}", normalize_ws: true
  end

  test "has day filter" do
    day = Time.now - 4.days
    render(pagy: pagy, date: day, mode: :day, reset_path: "")
    assert_text day.strftime("#{day.day.ordinalize} %B %Y")
  end

  test "has month filter" do
    day = Time.now - 4.days
    render(pagy: pagy, date: day, mode: :month, reset_path: "")
    assert_text day.strftime("%B %Y")
  end

  test "has reset filter link" do
    day = Time.now - 4.days
    render(pagy: pagy, date: day, mode: :month, reset_path: "example.com")
    assert_xpath "//a[@href=\"example.com\"]", text: I18n.t("button.reset")
  end
end

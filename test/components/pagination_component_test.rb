require "test_helper"

# Notes: We do not print pagination links unless we have > 0 count and > 1 pages
class PaginationComponentTest < ViewComponent::TestCase

  def render(_next: false, prev: false, pages: 0, series: [], count: 0, from: 0, to: 0)
    # Note: Stub out url_for as we don"t want to build a full pagy object
    PaginationComponent.any_instance.stubs(:pagy_url_for).returns("/pagination")
    render_inline(PaginationComponent.new(pagy: stub(
      next: _next,
      prev: prev,
      series: series,
      count: count,
      from: from,
      to: to,
      pages: pages
    )))
    assert_component_rendered
  end

  test "has previous" do
    render(prev: true, pages: 2, count: 1)
    assert_xpath "//a[@href='/pagination']", text: I18n.t("button.previous")
  end

  test "has next" do
    render(_next: true, pages: 2, count: 1)
    assert_xpath "//a[@href='/pagination']", text: I18n.t("button.next")
  end

  test "has current" do
    render(series: ["99"], pages: 2, count: 1)
    assert_xpath "//span", text: "99"
  end

  test "has links" do
    render(series: [1, 22, 4848], pages: 2, count: 1)
    assert_xpath "//a[@href='/pagination']", text: "1"
    assert_xpath "//a[@href='/pagination']", text: "22"
    assert_xpath "//a[@href='/pagination']", text: "4848"
  end

  test "has gap" do
    render(series: [1, :gap, 2], pages: 2, count: 1)
    assert_xpath "//span", text: I18n.t("pagination.gap")
  end

end

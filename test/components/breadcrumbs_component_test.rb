require "test_helper"

class BreadcrumbsComponentTest < ViewComponent::TestCase

  def render(crumbs)
    render_inline(BreadcrumbsComponent.new(crumbs))
    assert_component_rendered
  end

  test "empty" do
    render_inline(BreadcrumbsComponent.new([]))
    refute_component_rendered
  end

  test "one title" do
    render(["Help!"])
    assert_xpath "//span", text: "Help!"
  end

  test "only titles" do
    titles = ["a one", "b one", "c one"]
    render(titles)
    titles.each do |title|
      assert_xpath "//span", text: title
    end
  end

  test "one link" do
    render([["Help!", "https://google.com"]])
    assert_xpath "//a[@href=\"https://google.com\"]", text: "Help!"
  end

  test "only links" do
    links = [
      ["Alpha", "https://google.com"],
      ["Beta", "https://bing.com"]
    ]
    render(links)
    links.each do |link|
      assert_xpath "//a[@href=\"#{link.last}\"]", text: link.first
    end
  end

  test "breadcrumb trail" do
    links = [
      ["Alpha", "https://google.com"],
      ["Beta", "https://bing.com"],
      "Last Page!"
    ]
    render(links)
    links.each do |link|
      if link.is_a?(Array)
        assert_xpath "//a[@href=\"#{link.last}\"]", text: link.first
      else
        assert_xpath "//span", text: link
      end
    end
  end

  test "no SVGs" do
    render(["Help!"])
    refute_xpath "//svg"
  end

  test "with SVGs" do
    titles = ["a", "b", "c"]
    render(titles)
    assert_xpath "//svg", count: titles.length - 1
  end

end

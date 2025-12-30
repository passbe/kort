require "test_helper"

class ModalComponentTest < ViewComponent::TestCase

  def render(title:, description:, actions: nil)
    component = ModalComponent.new(
      title: title,
      description: description
    ).tap do |c|
      c.with_actions { actions }
    end
    render_inline(component)
    assert_component_rendered
  end

  test "has container" do
    render(title: "", description: "")
    assert_xpath "//div[@data-controller=\"modal\"]"
  end

  test "has close button" do
    render(title: "", description: "")
    assert_xpath "//button[@type=\"button\" and @data-action=\"modal#hide\"]"
  end

  test "has title" do
    title = "Modal title goes here!"
    render(title: title, description: "")
    assert_xpath "//h3", text: title
  end

  test "has description" do
    description = "Some important content you need to know about?"
    render(title: "", description: description)
    assert_xpath "//p", text: description
  end

  test "has cancel button" do
    render(title: "", description: "")
    assert_xpath "//a[@href=\"#cancel\" and @data-action=\"modal#hide\"]", text: I18n.t("button.cancel")
  end

  test "has actions" do
    render(title: "", description: "", actions: "<p>Actions!</p>".html_safe)
    assert_xpath "//p", text: "Actions!"
  end

end

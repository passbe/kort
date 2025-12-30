require "test_helper"

class FormHelptextComponentTest < ViewComponent::TestCase

  def render(errors: [], field: nil, error_heading: false, message: nil, success: false)
    render_inline(FormHelptextComponent.new(
      errors: errors,
      field: field,
      error_heading: error_heading,
      message: message,
      success: success
    ))
    assert_component_rendered
  end

  test "no errors renders nothing" do
    probe = build(:probe_dns)
    render_inline(FormHelptextComponent.new(errors: probe.errors, field: :base))
    refute_component_rendered
  end

  test "errors for another field renders nothing" do
    probe = build(:probe_dns)
    probe.errors.add(:name, "Some unique error")
    render_inline(FormHelptextComponent.new(errors: probe.errors, field: :base))
    refute_component_rendered
  end

  test "has error_heading" do
    probe = build(:probe_dns)
    probe.errors.add(:name, "Some unique error")
    render(errors: probe.errors, field: :name, error_heading: true)
    assert_xpath "//div/h4", text: I18n.t("heading.errors")
  end

  test "no error_heading" do
    probe = build(:probe_dns)
    probe.errors.add(:name, "Some unique error")
    render(errors: probe.errors, field: :name)
    assert_no_xpath "//div/h4", text: I18n.t("heading.errors")
  end

  test "single error message" do
    error = "Unique snowflake error message"
    probe = build(:probe_dns)
    probe.errors.add(:name, error)
    render(errors: probe.errors, field: :name)
    assert_xpath "//div[contains(@class, \"red\")]/p", text: error
  end

  test "multiple error messages" do
    errors = [
      "Unique snowflake error message",
      "Help an error has occured!"
    ]
    probe = build(:probe_dns)
    errors.each do |e|
      probe.errors.add(:name, e)
    end
    render(errors: probe.errors, field: :name)
    errors.each do |e|
      assert_xpath "//div[contains(@class, \"red\")]/p", text: e
    end
  end

  test "multiple error messages different fields - field specified" do
    probe = build(:probe_dns)
    message_a = "Test name error"
    message_b = "Base error message"
    probe.errors.add(:name, message_a)
    probe.errors.add(:base, message_b)
    render(errors: probe.errors, field: :name)
    assert_xpath "//div[contains(@class, \"red\")]/p", text: message_a
    assert_no_xpath "//div[contains(@class, \"red\")]/p", text: message_b
  end

  test "multiple error messages different fields - field not specified" do
    probe = build(:probe_dns)
    message_a = "Test name error"
    message_b = "Base error message"
    probe.errors.add(:name, message_a)
    probe.errors.add(:base, message_b)
    render(errors: probe.errors)
    assert_xpath "//div[contains(@class, \"red\")]/p", text: message_a
    assert_xpath "//div[contains(@class, \"red\")]/p", text: message_b
  end

  test "has success message" do
    message = "Hellooo!"
    render(message: message, success: true)
    assert_xpath "//div[contains(@class, \"green\")]/p", text: message
  end

  test "has helptext message" do
    message = "Hellooo! Helptext"
    render(message: message)
    assert_xpath "//div[contains(@class, \"gray\")]/p", text: message
  end

end

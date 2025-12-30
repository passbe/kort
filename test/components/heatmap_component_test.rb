require "test_helper"

class HeatmapComponentTest < ViewComponent::TestCase

  include Rails.application.routes.url_helpers

  def render(target:, months:)
    render_inline(HeatmapComponent.new(target: target, months: months))
    assert_component_rendered
  end

  test "has heading" do
    target = create(:probe_dns)
    render(target: target, months: 3)
    assert_text I18n.t("heading.heatmap", count: 3)
  end

  test "limits months to 12" do
    target = create(:probe_dns)
    render(target: target, months: 39999)
    assert_text I18n.t("heading.heatmap", count: 12)
  end

  test "has month link (probe)" do
    target = create(:probe_dns)
    render(target: target, months: 3)
    3.times do |i|
      cursor = Date.current - i.months
      assert_xpath "//a[@href=\"#{probe_path(target, month: cursor.strftime("%Y-%m"))}\"]", text: cursor.strftime("%B")
    end
  end

  test "has month link (interval)" do
    target = create(:interval)
    render(target: target, months: 3)
    3.times do |i|
      cursor = Date.current - i.months
      assert_xpath "//a[@href=\"#{interval_path(target, month: cursor.strftime("%Y-%m"))}\"]", text: cursor.strftime("%B")
    end
  end

  test "has day links (probe)" do
    target = create(:probe_dns)
    render(target: target, months: 3)
    ((Date.current - 2.months)..Date.current).each do |date|
      assert_xpath "//a[@href=\"#{probe_path(target, day: date.strftime("%Y-%m-%d"))}\" and @title=\"#{date.strftime("%e %B %Y")}\"]"
    end
  end

  test "has day links (interval)" do
    target = create(:interval)
    render(target: target, months: 3)
    ((Date.current - 2.months)..Date.current).each do |date|
      assert_xpath "//a[@href=\"#{interval_path(target, day: date.strftime("%Y-%m-%d"))}\" and @title=\"#{date.strftime("%e %B %Y")}\"]"
    end
  end

  ["bg-red-", "bg-yellow-", "bg-indigo-", "bg-green-", "bg-zinc-", "bg-zinc-"].each_with_index do |css, index|
    test "has day link with background for #{Execution::STATUSES.at(index)} (probe)" do
      target = create(:probe_dns)
      date = create(:execution, target: target, status: Execution::STATUSES.at(index)).created_at
      render(target: target, months: 1)
      assert_xpath "//a[@href=\"#{probe_path(target, day: date.strftime("%Y-%m-%d"))}\" and @title=\"#{date.strftime("%e %B %Y")}\" and contains(@class, \"#{css}\")]"
    end

    test "has day link with background for #{Execution::STATUSES.at(index)} (interval)" do
      target = create(:interval)
      date = create(:execution, target: target, status: Execution::STATUSES.at(index)).created_at
      render(target: target, months: 1)
      assert_xpath "//a[@href=\"#{interval_path(target, day: date.strftime("%Y-%m-%d"))}\" and @title=\"#{date.strftime("%e %B %Y")}\" and contains(@class, \"#{css}\")]"
    end
  end

end

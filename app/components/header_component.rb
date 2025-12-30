class HeaderComponent < ViewComponent::Base

  renders_one :status

  def initialize(title:, attributes: {}, statistics: {}, status: nil, status_css: nil)
    @title = title
    @attributes = attributes
    @statistics = statistics
    @status = status
    @status_css = status_css
  end

  def statistics
    @statistics.each do |key, value|
      yield key,
        (value.is_a?(Hash) ? value.dig(:value) : value),
        (value.is_a?(Hash) ? value.dig(:data) : nil)
    end
  end

end

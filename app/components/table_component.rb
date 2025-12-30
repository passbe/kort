class TableComponent < ViewComponent::Base

  def initialize(fields = [])
    @fields = fields
  end

  def render?
    !@fields.empty?
  end

  def rows
    @fields.each do |field|
      yield (field.is_a?(Hash) ? field.dig(:text) : field),
        (field.is_a?(Hash) ? "text-#{field.dig(:align)}" : "text-center")
    end
  end
end

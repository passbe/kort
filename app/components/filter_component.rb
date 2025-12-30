class FilterComponent < ViewComponent::Base

  def initialize(mode: nil, date: nil, reset_path: nil, pagy:)
    @mode = mode
    @date = date
    @path = reset_path
    @pagy = pagy
  end

end

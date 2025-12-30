class PaginationComponent < ViewComponent::Base

  include Pagy::Frontend

  def initialize(pagy:)
    @pagy = pagy
  end

  def render?
    @pagy.count > 0 and @pagy.pages > 1
  end

end

class BreadcrumbsComponent < ViewComponent::Base

  def initialize(crumbs)
    @crumbs = crumbs
  end

  def render?
    @crumbs.present?
  end

end

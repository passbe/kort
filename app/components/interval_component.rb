class IntervalComponent < ViewComponent::Base

  with_collection_parameter :interval

  def initialize(interval:)
    @interval = interval
  end

  def link_css
    "px-2 lg:px-4 py-2 block w-full h-full no-underline! hover:text-gray-300!"
  end

  def status_css
    [
      "px-2 lg:px-4 py-2 block w-full h-full no-underline!",
      {
        "text-green-400! hover:text-green-400!": @interval.enabled,
        "text-yellow-400! hover:text-yellow-400!": !@interval.enabled
      }
    ]
  end

end

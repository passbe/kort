class ProbeComponent < ViewComponent::Base

  with_collection_parameter :probe

  def initialize(probe:)
    @probe = probe
  end

  def link_css
    "px-2 lg:px-4 py-2 block w-full h-full no-underline! hover:text-gray-300!"
  end

  def status_css
    [
      "px-2 lg:px-4 py-2 block w-full h-full no-underline!",
      {
        "text-green-400! hover:text-green-400!": @probe.enabled,
        "text-yellow-400! hover:text-yellow-400!": !@probe.enabled
      }
    ]
  end

end

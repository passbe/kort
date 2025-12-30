class Probes::PortFormComponent < ViewComponent::Base

  include FormHelper

  def initialize(probe:)
    @probe = probe
  end

end

class Probes::DockerFormComponent < ViewComponent::Base

  include FormHelper

  def initialize(probe:)
    @probe = probe
  end

end

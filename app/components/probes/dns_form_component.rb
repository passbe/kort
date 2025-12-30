class Probes::DnsFormComponent < ViewComponent::Base

  include FormHelper

  def initialize(probe:)
    @probe = probe
  end

  def record_options
    Dnsruby::Types.strings.sort
  end

end

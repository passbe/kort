class ProbeFormComponent < ViewComponent::Base

  include FormHelper
  renders_one :actions

  def initialize(probe:)
    @probe = probe
  end

  def new_record?
    @probe.new_record?
  end

  def form_id
    "probe_form"
  end

  # DNS, /probes/new/fields/dns
  def subclasses
    Probe.subclasses.map { |p|
      [
        p.model_name.human,
        p,
        "data-location": fields_new_probe_path(type: p.name.demodulize.to_s.downcase, format: :turbo_stream),
        "data-type-selector-target": "option"
      ]
    }
  end

end

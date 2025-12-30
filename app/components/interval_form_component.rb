class IntervalFormComponent < ViewComponent::Base

  include FormHelper
  renders_one :actions

  def initialize(interval:)
    @interval = interval
  end

  def new_record?
    @interval.new_record?
  end

  def form_id
    "interval_form"
  end

end

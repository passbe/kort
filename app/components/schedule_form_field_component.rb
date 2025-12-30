class ScheduleFormFieldComponent < ViewComponent::Base

  with_collection_parameter :schedule

  def initialize(schedule:, schedule_counter: nil, without_grace: false)
    @schedule = schedule
    @index = schedule_counter || Time.now.to_i
    @without_grace = without_grace
  end

  def render?
    @schedule.expression.present?
  end

  def model
    @schedule.target_type_base_class.name.downcase
  end

  def form_id
    "#{model}_form"
  end

  def input_name(field:)
    "#{model}[schedules_attributes][#{@index}][#{field}]"
  end

  def input_id(field:)
    "#{model}_schedules_attributes_#{@index}_#{field}"
  end

end

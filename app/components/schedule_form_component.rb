class ScheduleFormComponent < ViewComponent::Base

  def initialize(schedule:, without_grace: false)
    @schedule = schedule
    @schedule.valid? # Force validations
    @without_grace = without_grace
  end

  def model
    @schedule.target_type_base_class.name.downcase
  end

  def blank?(field)
    @schedule.send(field).blank?
  end

  # Witin the UI we treat two fields as one - so we must join errors and validations
  # Note: We ignore :target errors as on create forms we don't know the target yet
  def expression_valid?
    @schedule.errors.where(:expression).empty? and
    @schedule.errors.where(:next_execution_at).empty?
  end

  def grace_valid?
    @schedule.errors.where(:grace).empty? and
    @schedule.errors.where(:grace_expires_at).empty?
  end

end

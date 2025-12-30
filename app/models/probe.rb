class Probe < ApplicationRecord

  include PrimaryUUID
  include StoreCasting
  include Schedules

  acts_as_taggable_on :tags
  has_many :executions, as: :target, dependent: :destroy

  validates :enabled, inclusion: [true, false]
  validates :name, presence: true
  validates :type, inclusion: {
    in: -> { Probe.subclasses.map(&:to_s) }
  }

  # Returns class for view_component (Probes::Dns > Probes::DnsFormComponent)
  def component_class
    begin
      kclass = "#{self.type}FormComponent".constantize
    rescue NameError
      nil
    end
  end

  # Returns Probes::Dns > Probes::DnsJob
  def job_class
    "#{self.class}Job".constantize
  end

  # Transforms type parameter to child class (dns > Probes::Dns)
  # Note: Raises NameError if invalid
  def self.type_class(param)
    Probes.const_get(param.humanize)
  end

  # Default evaluator - should be over-ridden in child class
  def evaluate(result)
    return false, I18n.t("evaluator.failure")
  end

  # Builds execution and fires job
  def execute(schedule: nil)
    execution = self.executions.build
    execution.schedule = schedule
    execution.pending!
    execution.save!
    # Output schedule (unless nil)
    if schedule
      schedule.debug.each do |line|
        execution.info line
      end
      execution.info ""
    end
    # Output details of Probe
    debug.each do |line|
      execution.info line
    end
    execution.info ""
    job_class.perform_later(execution, schedule)
    execution
  end

  # Return interval information for log
  def debug
    [
      Probe.model_name.human,
      "----",
      "#{Probe.human_attribute_name(:id)}: #{self.id}",
      "#{Probe.human_attribute_name(:name)}: #{self.name}",
      "#{Probe.human_attribute_name(:type)}: #{self.type}",
      "#{Probe.human_attribute_name(:settings)}:",
      JSON.pretty_generate(self.settings)
    ]
  end

end

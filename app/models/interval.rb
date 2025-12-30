class Interval < ApplicationRecord

  include PrimaryUUID
  include Schedules

  acts_as_taggable_on :tags
  has_many :executions, as: :target, dependent: :destroy

  validates :enabled, inclusion: [true, false]
  validates :name, presence: true

  def impending(schedule: nil)
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
    # Output details of Interval
    debug.each do |line|
      execution.info line
    end
    execution.info ""
    execution
  end

  # Return interval information for log
  def debug
    [
      Interval.model_name.human,
      "----",
      "#{Interval.human_attribute_name(:id)}: #{self.id}",
      "#{Interval.human_attribute_name(:name)}: #{self.name}"
    ]
  end

end

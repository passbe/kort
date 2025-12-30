class Schedule < ApplicationRecord

  include PrimaryUUID

  belongs_to :target, polymorphic: true, counter_cache: true
  has_many :executions, dependent: :nullify

  validates :expression, presence: true
  validates :next_execution_at, presence: true, on: :create
  validates :expression, uniqueness: { scope: :target }
  validate :validate_expression
  validate :validate_grace, unless: -> { grace.nil? }
  validates :grace_expires_at, presence: true, unless: -> { grace.nil? }

  broadcasts_refreshes_to :target

  # Note: See expired?
  scope :expired, -> {
    where("next_execution_at IS NULL OR next_execution_at <= ?", Time.now)
    .where("grace_expires_at IS NULL OR grace_expires_at <= ?", Time.now)
  }

  # Force next generation reload on change
  def expression=(value)
    super(value)
    generate_next_execution_at
  end

  # Force next grace reload on change
  def grace=(value)
    super(value)
    generate_grace_expires_at unless grace.blank? or next_execution_at.blank?
  end

  # A hack?
  # At times we need Probe not Probes::Dns
  def target_type_base_class
    klass = target_type.constantize
    klass = klass.superclass if target_type.include? "::"
    klass
  end

  # Reset the schedule to update all values for the next iteration
  def reset!
    generate_next_execution_at
    unless next_execution_at.nil?
      generate_grace_expires_at unless grace.blank?
    end
    save!
  end

  # Return schedule information for log
  def debug
    lines = [
      Schedule.model_name.human,
      "----",
      "#{Schedule.human_attribute_name(:id)}: #{self.id}",
      "#{Schedule.human_attribute_name(:expression)}: #{self.expression}",
      "#{I18n.t("schedule.calculated")}: #{self.next_execution_at}"
    ]
    lines << "#{Schedule.human_attribute_name(:grace)}: #{self.grace}" unless
      grace.nil?
    lines << "#{Schedule.human_attribute_name(:grace_expires_at)}: #{self.grace_expires_at}" unless
      self.grace_expires_at.nil?
    lines
  end

  # Returns boolean if schedule has expired
  # Note: Without grace, a schedule is expired after no new executions can be generated (ie: nil)
  #       With grace, a schedule can be expired, after grace, or after no new executions (ie: nil)
  def expired?
    grace_expired = self.grace_expires_at.nil? ? true : self.grace_expires_at < Time.now
    execution_expired = self.next_execution_at.nil? ? true : self.next_execution_at < Time.now
    grace_expired and execution_expired
  end

  # Integer in seconds from now to grace_expires_at
  def grace_expires_secs
    return nil if grace_expires_at.nil?
    (grace_expires_at - Time.now).round.to_i
  end

  # Integer in seconds from now until next_execution_at
  def next_execution_secs
    return nil if next_execution_at.nil?
    (next_execution_at - Time.now).round.to_i
  end

  private

  # Validate we have a valid OnCalendar expression
  def validate_expression
    OnCalendar::Parser.new(expression)
  rescue OnCalendar::Parser::Error => e
    errors.add(:expression, I18n.t("schedule.expression.invalid"))
  end

  # Generate time for when the next execution due
  # Note: This is hyper dependent on when we execute this around time. Therefore we generate the next two occurences. If the first occurence is now discard and use the second
  def generate_next_execution_at
    self.next_execution_at = OnCalendar::Parser.new(expression).next&.first
  rescue OnCalendar::Parser::Error
    self.next_execution_at = nil
  end

  # Note: Fugit::Duration.parse doesn't return nil on blank grace
  def validate_grace
    errors.add(:grace, I18n.t("schedule.grace.invalid")) if
      grace.blank? or
      Fugit::Duration.parse(grace).nil?
  end

  # Generate the next time that grace should expire at
  def generate_grace_expires_at
    self.grace_expires_at = Fugit::Duration
      .parse(grace)
     &.next_time(next_execution_at)
     &.to_local_time
  end

end

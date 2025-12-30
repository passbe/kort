class Execution < ApplicationRecord

  LOG_LEVELS = %w[ debug info warn error fatal ]

  include PrimaryUUID
  include Statuses

  attr_reader :logger, :result

  belongs_to :target, polymorphic: true
  belongs_to :schedule, optional: true
  validates :target, :log_identifier, :counter, presence: true
  before_validation :generate_log_identifier
  before_validation :increment_counter, if: -> { counter.nil? }

  after_destroy :purge_log

  broadcasts_refreshes
  default_scope { order(created_at: :desc) }

  # Allow 0 and 1
  def status=(value)
    value = value.to_i if value.is_a?(String) && value.match(/[0-9]/)
    if value.is_a?(Integer) && value >= 0
      value = value == 0 ? Execution::Status::SUCCESS : Execution::Status::FAILURE
    end
    super(value)
  end

  # Get next execution
  def next_by_created_at
    self.class
      .where(target: target)
      .where("created_at > ?", created_at)
      .reorder(created_at: :asc)
      .first
  end

  # Get previous execution
  # Note: default_scope orders correctly here
  def previous_by_created_at
    self.class
      .where(target: target)
      .where("created_at < ?", created_at)
      .first
  end

  # Helpers
  def probe
    self.target
  end

  def interval
    self.target
  end

  # Returns path for log_file
  def log_file
    return nil if self.target.nil? or self.created_at.nil? or self.log_identifier.nil?
    Rails.root.join(
      "storage",
      "logs",
      self.created_at.strftime("%Y-%m"),
      "#{self.target_type.downcase}_#{self.log_identifier}.log"
    )
  end

  # Setup logging helper methods that also broadcast refreshes
  LOG_LEVELS.each do |level|
    define_method(level) do |message = nil, &block|
      self.prepare_log if logger.nil?
      unless logger.nil?
        logger.add(Logger.const_get(level.upcase), message, nil, &block)
      end
      self.broadcast_refresh
    end
  end

  # Helper method to log a message based on error level
  def log_by_status(message)
    level = "info"
    level = "error" if self.status == Execution::Status::FAILURE
    level = "warn" if self.status == Execution::Status::WARNING
    self.send(level, message)
  end

  # Helper method to log by level
  def log_by_level(message, level)
    level = "info" unless LOG_LEVELS.include?(level)
    self.send(level, message)
  end

  def message!(str)
    self.message = str
  end

  # Evaluate results of job to determine outcome
  def evaluate(result)
    @result = result
    # Default to hard coded evaluate function should the user not supply one
    if self.target.evaluator.blank?
      outcome, msg = self.target.evaluate(result)
      self.status = outcome ? Execution::Status::SUCCESS : Execution::Status::FAILURE
      self.message = msg
    # Use user supplied function
    else
      self.warn "Using custom evaluator function"
      # Warning: Most dangerous part of the code base below
      self.instance_eval(self.target.evaluator)
    end
    save!
  end

  # Integer in seconds execution has been pending
  def pending_secs
    cursor = started_at || Time.now
    (cursor - created_at).round.to_i
  end

  # Integer in seconds execution has been executing
  def elapsed_secs
    return nil if started_at.nil?
    cursor = finished_at || Time.now
    (cursor - started_at).round.to_i
  end

  private

  # Create log file and keep open handle
  def prepare_log
    # Lets not pollute test
    return if Rails.env.test?
    path = log_file
    if path
      # Create directories
      FileUtils.mkdir_p(path.dirname) unless File.directory?(path.dirname)
      # Set logger
      @logger = ActiveSupport::Logger.new(path, skip_header: true)
      @logger.debug!
      @logger.formatter = proc { |severity, time, progname, msg|
        "[#{time.strftime("%Y-%m-%dT%H:%M:%S.%6N")}][#{severity}] #{msg}\n"
      }
    end
  end

  def purge_log
    return if Rails.env.test? or self.log_file.nil?
    file = self.log_file
    File.delete(file) if File.exist?(file)
  end

  def generate_log_identifier
    self.log_identifier = SecureRandom.uuid if self.log_identifier.nil?
  end

  def increment_counter
    prev_counter = Execution.where(target: self.target).order(created_at: :desc).pick(:counter) || 0
    self.counter = prev_counter += 1
  end

end

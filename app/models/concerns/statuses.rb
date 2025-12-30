module Statuses
  extend ActiveSupport::Concern

  module Status
    PENDING = "pending"
    STARTED = "started"
    SUCCESS = "success"
    SKIPPED = "skipped"
    WARNING = "warning"
    FAILURE = "failure"
  end

  STATUSES = [
    Status::FAILURE, Status::WARNING, Status::SKIPPED, Status::SUCCESS, Status::STARTED, Status::PENDING
  ]

  included do
    validates :status, inclusion: { in: STATUSES }
  end

  # Set status to callee or argument
  def set_status!(new_status = nil)
    self.status = (new_status.nil?) ? __callee__.to_s.tr("!", "") : new_status
    self
  end
  # Alias helper methods
  STATUSES.each { alias_method "#{_1}!", :set_status! }

  # Is status to callee
  def is_status?
    self.status == __callee__.to_s.tr("?", "")
  end
  # Alias helper methods
  STATUSES.each { alias_method "#{_1}?", :is_status? }
end

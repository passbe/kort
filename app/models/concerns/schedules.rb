module Schedules
  extend ActiveSupport::Concern

  included do
    has_many :schedules, as: :target, dependent: :destroy
    accepts_nested_attributes_for :schedules, allow_destroy: true
  end

  # Get next schedules by execution_next_at
  def next_schedule
    schedules
      .where("next_execution_at > ?", Time.now)
      .order(:next_execution_at)
      .first
  end

  # Retrieve current grace schedule
  def current_grace_schedule
    schedules
      .where("next_execution_at < ?", Time.now)
      .where("grace_expires_at > ?", Time.now)
      .order(:next_execution_at)
      .first
  end
end

class ProbeJob < ApplicationJob

  queue_as :probes

  # Start execution job
  before_perform do |job|
    execution = job.arguments.first
    execution.started_at = Time.now
    execution.started!
    execution.save!
  end

  # Capture return or error
  around_perform do |job, block|
    execution = job.arguments.first
    begin
      execution.evaluate(block.call)
      # Default to warning if no status was previously set
      if execution.started? or execution.pending?
        execution.warning!
        execution.warn I18n.t("execution.default_warn")
      end
      execution.finished_at = Time.now
      execution.save!
    rescue StandardError, SyntaxError => e
      execution.message = e
      execution.error e.message
      e.backtrace.each do |line|
        execution.error line
      end
      execution.failure!
      execution.finished_at = Time.now
      execution.save!
    end
  end

end

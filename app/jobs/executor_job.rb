class ExecutorJob < ApplicationJob

  queue_as :system

  def perform(*args)
    # Build from..to date range
    # Note: We floor the from range in case this job took a second to be executed
    # Note: -1 on to due to SQLITE BETWEEN including
    now = Time.now.to_i
    from = Time.at(now - (now % Rails.application.config.executor_seconds.seconds))
    to = from + (Rails.application.config.executor_seconds.seconds - 1)

    # Get all schedules within our date range
    Schedule.preload(:target).where(next_execution_at: [from..to]).each do |schedule|

      # Note: We can't use SQL here because of polymorphic association
      next unless schedule.target.enabled

      # If we are an interval - lets create pending execution
      if schedule.target.is_a? Interval
        # Create pending execution
        schedule.target.impending(schedule: schedule)
      # If we are a probe - execute and reset schedule
      else
        # Build class and fire job
        schedule.target.execute(schedule: schedule)
        # Restart schedule
        schedule.reset!
      end

    end

    # Retrieve expired schedules - reset them - mark Intervals as failure
    # Note: This will also reset schedules that have been missed - ie: application shutdown
    Schedule.preload(:target).expired.each do |schedule|
      # Reset schedule
      schedule.reset!

      # # If Interval mark latest execution as failure
      if schedule.target.is_a? Interval
        schedule.target.executions.where(status: [Execution::Status::PENDING, Execution::Status::STARTED]).each do |execution|
          if execution.status == Execution::Status::PENDING
            execution.message = I18n.t("execution.no_signal")
            execution.error I18n.t("execution.no_signal")
          else
            execution.message = I18n.t("execution.late")
            execution.error I18n.t("execution.late")
          end
          execution.failure!
          execution.save!
        end
      end
    end
  end

end

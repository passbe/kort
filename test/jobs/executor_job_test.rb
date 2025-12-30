require "test_helper"

class ExecutorJobTest < ActiveJob::TestCase

  # Helper method to pin time across all tests
  def pinned_time
    Time.local(2000, 1, 2, 0, 0, 0)
  end

  # Helper to pin executor seconds
  def pinned_seconds
    Rails.application.config.executor_seconds
  end

  # Create schedule - by default the factory will not call generate_next_execution_at - we need this to be accurate for these time pinned tests to work.
  def schedule(target, expression_time, grace = nil)
    schedule = build(:schedule,
      target: target,
      expression: expression_time.strftime("%Y-%m-%d %H:%M:%S"),
      grace: grace
    )
    schedule.reset!
    schedule
  end

  # Helper to only provide probe jobs
  # Note: At times Turbo::Stream amoung other pollute our job queue - lets filter here
  def executor_jobs
    enqueued_jobs.select { |job|
      job["queue_name"] == "probes"
    }.sort_by { |job|
      Time.parse(job["enqueued_at"])
    }.reverse
  end

  # Note: We make some assumptions below that require 5 seconds here
  test "Rails.application.config.executor_seconds >= 5" do
    assert_operator pinned_seconds, :>=, 5
  end

  class ProbeTarget < ExecutorJobTest

    test "no schedules" do
      assert_equal 0, Schedule.count
      perform_enqueued_jobs do
        ExecutorJob.perform_later
      end
      assert_equal 0, executor_jobs.length
    end

    test "ignores disabled probe" do
      travel_to pinned_time do
        schedule(create(:probe_dns, enabled: false), pinned_time + 1.seconds)
        ExecutorJob.perform_now
        assert_equal 0, executor_jobs.length
      end
    end

    test "one schedule" do
      travel_to pinned_time do
        target = create(:probe_dns)
        schedule(target, pinned_time + (pinned_seconds - 1).seconds)
        # Dummy
        schedule(target, pinned_time + (pinned_seconds + 1).seconds)
        # Ensure job queued
        assert_enqueued_with(job: Probes::DnsJob, queue: "probes") do
          ExecutorJob.perform_now
        end
        assert_equal 1, executor_jobs.length
      end
    end

    test "one schedule (delayed execution)" do
      travel_to pinned_time
      target = create(:probe_dns)
      schedule(target, pinned_time + (pinned_seconds - 2).seconds)
      # Emulate the job running delayed (ie: 1 second after the schedule above)
      travel_to pinned_time + (pinned_seconds - 1).seconds
      # Ensure job queued
      assert_enqueued_with(job: Probes::DnsJob, queue: "probes") do
        ExecutorJob.perform_now
      end
      assert_equal 1, executor_jobs.length
    end

    test "multiple schedules one target" do
      travel_to pinned_time do
        target = create(:probe_dns)
        schedule(target, pinned_time + (pinned_seconds - 3).seconds)
        schedule(target, pinned_time + (pinned_seconds - 2).seconds)
        # Dummy
        schedule(target, pinned_time + pinned_seconds.seconds)
        # Ensure job queued
        assert_enqueued_with(job: Probes::DnsJob, queue: "probes") do
          ExecutorJob.perform_now
        end
        assert_equal 2, executor_jobs.length
      end
    end

    test "multiple schedules multiple targets" do
      travel_to pinned_time do
        target_a = create(:probe_dns)
        target_b = create(:probe_dns)
        schedule(target_a, pinned_time + (pinned_seconds - 4).seconds)
        schedule(target_b, pinned_time + (pinned_seconds - 3).seconds)
        # Dummy
        schedule(target_a, pinned_time + (pinned_seconds + 80).seconds)
        # Ensure job queued
        assert_enqueued_with(job: Probes::DnsJob, queue: "probes") do
          ExecutorJob.perform_now
        end
        assert_equal 2, executor_jobs.length
      end
    end

    test "calls :reset! on schedule during execution" do
      travel_to pinned_time do
        target = create(:probe_dns)
        schedule(target, pinned_time + (pinned_seconds - 2).seconds)
        Schedule.any_instance.expects(:reset!).returns(true)
        ExecutorJob.perform_now
      end
    end

    test "calls :reset! on expired schedule" do
      travel_to pinned_time + 1.minute do
        interval = create(:probe_dns)
        schedule = create(:schedule,
          target: interval,
          expression: "Mon",
          next_execution_at: pinned_time,
          grace: "1s",
          grace_expires_at: pinned_time + 1.second
        )
        assert schedule.expired?
        Schedule.any_instance.expects(:reset!).returns(true)
        ExecutorJob.perform_now
      end
    end

    # Note: Had problems in the past with timing - this test is designed to stress test the timing
    test "brute force timing" do
      # Create a schedule for every second
      # Note: here we create two schedules before and after the 90 we test to ensure we don't queue those
      schedules = []
      target = create(:probe_port)
      travel_to pinned_time - 10.minutes do
        (0..94).each do |i|
          schedules << schedule(target, (pinned_time - 2.seconds) + i.seconds)
        end
      end

      # Loop over our schedules in groups of 5 running the Executor every 5 seconds (offset by +1 second)
      # Note: we exclude the 4 dummy jobs (2 before, 2 after)
      schedules[2..91].each_slice(pinned_seconds).with_index do |slice, index|
        travel_to pinned_time + (index * pinned_seconds + 1) do
          ExecutorJob.perform_now
          cursor_jobs = executor_jobs
          # Make sure we only have 5 probe jobs queued
          assert_equal pinned_seconds, cursor_jobs.length
          # Check the jobs exist
          cursor_jobs.each_with_index do |job, index|
            schedule = GlobalID::Locator.locate(job["arguments"].last["_aj_globalid"])
            assert_equal schedule, slice.at(index)
          end
          clear_enqueued_jobs
        end
      end
    end

  end

  class IntervalTarget < ExecutorJobTest

    test "no schedules" do
      assert_equal 0, Schedule.count
      perform_enqueued_jobs do
        ExecutorJob.perform_later
      end
      assert_equal 0, Execution.count
    end

    test "ignores disabled interval" do
      travel_to pinned_time do
        schedule(create(:interval, enabled: false), pinned_time + 1.seconds)
        ExecutorJob.perform_now
        assert_equal 0, Execution.count
      end
    end

    test "calls :impending" do
      travel_to pinned_time do
        schedule(create(:interval), pinned_time + 1.seconds)
        Interval.any_instance.expects(:impending).returns(true)
        ExecutorJob.perform_now
      end
    end

    test "calls :reset! on expired" do
      travel_to pinned_time + 1.minute do
        interval = create(:interval)
        schedule = create(:schedule,
          target: interval,
          expression: "Mon",
          next_execution_at: pinned_time,
          grace: "1s",
          grace_expires_at: pinned_time + 1.second
        )
        assert schedule.expired?
        Schedule.any_instance.expects(:reset!).returns(true)
        ExecutorJob.perform_now
      end
    end

    test "sets execution when no signal on expired execution" do
      travel_to pinned_time + 1.minute do
        interval = create(:interval)
        schedule = create(:schedule,
          target: interval,
          expression: "Mon",
          next_execution_at: pinned_time,
          grace: "1s",
          grace_expires_at: pinned_time + 1.second
        )
        execution = create(:execution,
          target: interval,
          status: Execution::Status::PENDING,
          schedule: schedule
        )
        assert schedule.expired?
        ExecutorJob.perform_now
        execution.reload
        assert execution.failure?
        assert_equal I18n.t("execution.no_signal"), execution.message
      end
    end

    test "sets execution on late execution" do
      travel_to pinned_time + 1.minute do
        interval = create(:interval)
        schedule = create(:schedule,
          target: interval,
          expression: "Mon",
          next_execution_at: pinned_time,
          grace: "1s",
          grace_expires_at: pinned_time + 1.second
        )
        execution = create(:execution,
          target: interval,
          status: Execution::Status::STARTED,
          schedule: schedule,
          started_at: pinned_time
        )
        ExecutorJob.perform_now
        execution.reload
        assert execution.failure?
        assert_equal I18n.t("execution.late"), execution.message
      end
    end

  end

end

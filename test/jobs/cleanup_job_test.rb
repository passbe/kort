require "test_helper"

class CleanupJobTest < ActiveJob::TestCase

  test "no executions to cleanup" do
    create(:execution, created_at: Time.now - 1.week)
    create(:execution, created_at: Time.now - 2.week)
    create(:execution, created_at: Time.now - 3.week)
    assert_equal 3, Execution.count
    perform_enqueued_jobs do
      CleanupJob.perform_later(retention_months: 1)
    end
    assert_equal 3, Execution.count
  end

  test "executions cleanup" do
    create(:execution, created_at: Time.now - 1.month)
    create(:execution, created_at: Time.now - 2.month)
    create(:execution, created_at: Time.now - 3.week)
    assert_equal 3, Execution.count
    perform_enqueued_jobs do
      CleanupJob.perform_later(retention_months: 1)
    end
    assert_equal 1, Execution.count
  end

end

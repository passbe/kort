require "test_helper"

class ProbeJobTest < ActiveJob::TestCase

  test "job is enqueued correctly" do
    assert_enqueued_with(job: ProbeJob, queue: :probes) do
      ProbeJob.perform_later(create(:execution))
    end
  end

  test "catches StandardError" do
    execution = create(:execution)
    ProbeJob.any_instance.expects(:perform).raises(StandardError)
    ProbeJob.perform_now(execution)
  end

end

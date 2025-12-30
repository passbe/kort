require "test_helper"

class Probes::PortJobTest < ActiveJob::TestCase

  [Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ENETUNREACH, Timeout::Error].each do |exception|
    test "catches #{exception}" do
      execution = build(:execution, target: create(:probe_port))
      TCPSocket.any_instance.expects(:initialize).with(
        execution.probe.host,
        execution.probe.port
      ).raises(exception)
      assert_equal false, Probes::PortJob.perform_now(execution, nil)
    end
  end

end

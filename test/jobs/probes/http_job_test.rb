require "test_helper"

class Probes::HttpJobTest < ActiveJob::TestCase

  test "fires request" do
    probe = create(:probe_http,
      url: "http://test.com",
      method: "POST",
      body: "TEST!"
    )
    execution = build(:execution, target: probe)
    HTTP::Client.any_instance.expects(:request).with(probe.method, probe.url, { body: probe.body }).returns(true)
    Probes::HttpJob.perform_now(execution, nil)
  end

end

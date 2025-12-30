require "test_helper"

class ProbeTest < ActiveSupport::TestCase

  include ActiveJob::TestHelper

  class Validations < ProbeTest

    test "default valid" do
      assert build(:probe).valid?
    end

    test ":enabled nil is invalid" do
      assert_not build(:probe, enabled: nil).valid?
    end

    test ":name nil is invalid" do
      assert_not build(:probe, name: nil).valid?
    end

    test ":type nil is invalid" do
      assert_not build(:probe, type: nil).valid?
    end

    test ":type not subclass of Probes::" do
      assert_not build(:probe, type: "Probes::Tester").valid?
      assert_not build(:probe, type: "Probe").valid?
      assert_not build(:probe, type: "abc").valid?
    end

  end

  class Logic < ProbeTest

    test "destorying probe destroys schedules association" do
      probe = create(:probe)
      schedule = create(:schedule, target: probe)
      assert_equal schedule, probe.schedules.first
      probe.destroy
      assert_equal 0, Schedule.count
    end

  end

  class Methods < ProbeTest

    test ":component_class returns ViewComponent class" do
      probe = build(:probe_dns)
      assert_equal Probes::DnsFormComponent, probe.component_class
    end

    test ":component_class with invalid :type" do
      probe = build(:probe_dns, type: "bad")
      assert_nil probe.component_class
    end

    test ":job_class" do
      assert_equal Probes::DnsJob, build(:probe_dns).job_class
    end

    test ":type_class with invalid param" do
      assert_raise NameError do
        assert_nil Probe.type_class("invalid")
      end
      assert_raise NameError do
        assert_nil Probe.type_class(nil)
      end
    end

    test ":type_class with valid param" do
      assert_equal Probes::Dns, Probe.type_class("dns")
    end

    test ":evaluate should return false with message" do
      outcome, message = build(:probe).evaluate(nil)
      assert_not outcome
      assert_equal I18n.t("evaluator.failure"), message
    end

    test ":execute creates pending execution" do
      probe = create(:probe_dns)
      execution = probe.execute
      assert_instance_of Execution, execution
      assert probe, execution.probe
      assert execution.pending?
    end

    test ":execute queues job" do
      assert_enqueued_with(job: Probes::DnsJob) do
        create(:probe_dns).execute
      end
    end

    test ":next_schedule nil" do
      probe = create(:probe_dns)
      assert_nil probe.next_schedule
      create(:schedule, next_execution_at: Time.now - 1.minute, target: probe)
      assert_nil probe.next_schedule
    end

    test ":next_schedule" do
      probe = create(:probe_dns)
      schedule = create(:schedule, next_execution_at: Time.now + 1.minute, target: probe)
      # Dummy
      create(:schedule, expression: "Tue", next_execution_at: Time.now + 2.minute, target: probe)
      assert_equal schedule, probe.next_schedule
    end

  end

end

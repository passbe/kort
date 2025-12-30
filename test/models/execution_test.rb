require "test_helper"

class ExecutionTest < ActiveSupport::TestCase

  class Validations < ExecutionTest

    test "default valid" do
      assert build(:execution).valid?
    end

    test ":target nil is invalid" do
      assert_not build(:execution, target: nil).valid?
    end

    test ":status nil is invalid" do
      assert_not build(:execution, status: nil).valid?
    end

    test ":status empty is invalid" do
      assert_not build(:execution, status: "").valid?
    end

    test ":log_identifier empty is invalid" do
      assert_not build(:execution, log_identifier: "").valid?
    end

  end

  class Logic < ExecutionTest

    test ":log_identifier is generated" do
      execution = build(:execution, log_identifier: nil)
      execution.save!
      assert_not_nil execution.log_identifier
    end

    test ":log_identifier should not be re-generated" do
      execution = build(:execution, log_identifier: nil)
      execution.save!
      prev = execution.log_identifier
      execution.update(message: "Help testing!")
      assert_equal prev, execution.log_identifier
    end

    test ":counter 1 when first" do
      target_a = create(:probe_dns)
      assert_equal 1, create(:execution, target: target_a).counter
      target_b = create(:probe_dns)
      assert_equal 1, create(:execution, target: target_b).counter
    end

    test ":counter +1" do
      target = create(:probe_dns)
      assert_equal 1, create(:execution, target: target).counter
      assert_equal 2, create(:execution, target: target).counter
      assert_equal 3, create(:execution, target: target).counter
    end

  end

  class Methods < ExecutionTest

    test ":next_by_created_at" do
      freeze_time do
        target = create(:probe_dns)
        execution_cursor = create(:execution, target: target)
        execution_expected = create(:execution, target: target, created_at: Time.now + 1.second)
        # Dummy
        create(:execution, target: target, created_at: Time.now + 2.second)
        create(:execution, created_at: Time.now + 1.second)
        assert_equal execution_expected, execution_cursor.next_by_created_at
      end
    end

    test ":next_by_created_at nil" do
      assert_nil create(:execution).next_by_created_at
    end

    test ":previous_by_created_at" do
      freeze_time do
        target = create(:probe_dns)
        execution_cursor = create(:execution, target: target)
        execution_expected = create(:execution, target: target, created_at: Time.now - 1.second)
        # Dummy
        create(:execution, target: target, created_at: Time.now - 2.second)
        create(:execution, created_at: Time.now - 1.second)
        assert_equal execution_expected, execution_cursor.previous_by_created_at
      end
    end

    test ":previous_by_created_at nil" do
      assert_nil create(:execution).previous_by_created_at
    end

    test ":message!" do
      message = "this is a test message"
      execution = build(:execution, message: nil)
      execution.message! message
      assert_equal message, execution.message
    end

    test ":log_file nil target" do
      assert_nil build(:execution, target: nil).log_file
    end

    test ":log_file nil created_at" do
      assert_nil build(:execution, created_at: nil).log_file
    end

    test ":log_file nil log_identifier" do
      assert_nil build(:execution, log_identifier: nil).log_file
    end

    test ":log_file returns path" do
      travel_to Time.local(2000, 01, 01, 00, 00, 00)
      execution = create(:execution)
      pathname = execution.log_file
      assert_instance_of Pathname, pathname
      assert pathname.to_s.ends_with?("storage/logs/2000-01/probe_#{execution.log_identifier}.log")
    end

    test ":evaluate with default success" do
      execution = create(:execution, target: create(:probe, evaluator: nil))
      result = "noobj"
      message = "yay"
      Probe.any_instance.expects(:evaluate).returns(true, message)
      execution.evaluate(result)
      assert_equal result, execution.result
      assert execution.success?
      assert message, execution.message
    end

    test ":evaluate with default failure" do
      execution = create(:execution, target: create(:probe, evaluator: nil))
      result = "noobj"
      message = "noooooooo"
      Probe.any_instance.expects(:evaluate).returns(false, message)
      execution.evaluate(result)
      assert_equal result, execution.result
      assert execution.failure?
      assert message, execution.message
    end

    test ":evaluate with target evaluator" do
      execution = create(:execution, target: create(:probe, evaluator: "skipped!; self.message = 'howdy'"))
      result = "noobj"
      execution.evaluate(result)
      assert_equal result, execution.result
      assert execution.skipped?
      assert "howdy", execution.message
    end

    Execution::LOG_LEVELS.each do |level|
      test ":#{level} broadcasts" do
        execution = build(:execution)
        # Bypass test check
        execution.instance_variable_set(:@logger, stub(add: true))
        execution.expects(:broadcast_refresh).returns(true)
        execution.send(level)
      end
    end

    test ":pending_secs with :started_at" do
      execution = build(:execution,
        created_at: Time.local(2000, 01, 01, 0, 0, 0),
        started_at: Time.local(2000, 01, 01, 0, 0, 52),
      )
      assert_equal 52, execution.pending_secs
    end

    test ":pending_secs with :started_at nil" do
      execution = build(:execution,
        created_at: Time.local(2000, 01, 01, 0, 0, 0)
      )
      travel_to Time.local(2000, 01, 01, 0, 0, 52) do
        assert_equal 52, execution.pending_secs
      end
    end

    test ":elapsed_secs with :finished_at" do
      execution = build(:execution,
        started_at: Time.local(2000, 01, 01, 0, 0, 0),
        finished_at: Time.local(2000, 01, 01, 0, 15, 1)
      )
      assert_equal 901, execution.elapsed_secs
    end

    test ":elapsed_secs with :finished_at nil" do
      execution = build(:execution,
        started_at: Time.local(2000, 01, 01, 0, 0, 0)
      )
      travel_to Time.local(2000, 01, 02, 14, 8, 2) do
        assert_equal 137282, execution.elapsed_secs
      end
    end

    test ":elapsed_secs with :started_at nil" do
      execution = build(:execution, started_at: nil)
      assert_nil execution.elapsed_secs
    end

    test ":status= allows 0 integer as success" do
      execution = build(:execution, status: nil)
      [0, "0"].each do |value|
        execution.status = value
        assert execution.success?
      end
    end

    test ":status= allows > 1 integer as failure" do
      execution = build(:execution, status: nil)
      [1, "1", 999, 11, "983243343434", 42].each do |value|
        execution.status = value
        assert execution.failure?
      end
    end

    test ":status= allows Execution::STATUSES" do
      execution = build(:execution, status: nil)
      Execution::STATUSES.each do |value|
        execution.status = value
        assert execution.send("#{value}?")
      end
    end

    test ":status= with invalid attributes" do
      execution = build(:execution, status: nil)
      [-1, "-1", "abc"].each do |value|
        execution.status = value
        assert_equal value.to_s, execution.status
      end
      execution.status = nil
      assert_nil execution.status
    end

    test ":log_by_status :failure" do
      execution = create(:execution, status: Execution::Status::FAILURE)
      execution.expects(:error).with("log message").returns(true)
      execution.log_by_status("log message")
    end

    test ":log_by_status :warning" do
      execution = create(:execution, status: Execution::Status::WARNING)
      execution.expects(:warn).with("log message").returns(true)
      execution.log_by_status("log message")
    end

    test ":log_by_status default" do
      Execution::STATUSES.each do |status|
        next if [Execution::Status::FAILURE, Execution::Status::WARNING].include?(status)
        execution = create(:execution, status: status)
        execution.expects(:info).with("log message").returns(true)
        execution.log_by_status("log message")
      end
    end

  end

end

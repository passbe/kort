require "test_helper"

class ScheduleTest < ActiveSupport::TestCase

  class Validations < ScheduleTest

    test "default valid" do
      assert build(:schedule).valid?
    end

    test ":expression nil is invalid" do
      assert_not build(:schedule, expression: nil).valid?
    end

    test ":expression blank is invalid" do
      assert_not build(:schedule, expression: "").valid?
    end

    test ":expression malformed is invalid" do
      assert_not build(:schedule, expression: "@@").valid?
    end

    test ":next_execution_at nil on create is invalid" do
      assert_not build(:schedule, next_execution_at: nil).valid?
    end

    test ":next_execution_at nil on update is valid" do
      schedule = create(:schedule)
      schedule.next_execution_at = nil
      assert schedule.valid?
    end

    test ":grace blank is invalid" do
      assert_not build(:schedule, grace: "").valid?
    end

    test ":grace malformed is invalid" do
      assert_not build(:schedule, grace: "11MHY").valid?
    end

    test ":grace_expires_at blank is invalid" do
      assert_not build(:schedule, grace: "1m").valid?
    end

    test ":target nil is invalid" do
      assert_not build(:schedule, target: nil).valid?
    end

    test ":expression unique scoped :target" do
      schedule = create(:schedule)
      assert_not build(:schedule, expression: schedule.expression, target: schedule.target).valid?
    end

    test ":expression unique acrosss :target" do
      schedule = create(:schedule)
      assert build(:schedule, expression: schedule.expression).valid?
    end

  end

  class Logic < ScheduleTest

    test ":next_execution_at is generated" do
      schedule = build(:schedule, expression: nil, next_execution_at: nil)
      assert_nil schedule.next_execution_at
      schedule.expression = "Mon"
      assert_not_nil schedule.next_execution_at
    end

    test ":grace_expires_at is generated" do
      travel_to Time.local(2000, 1, 1, 0, 0, 0)
      schedule = build(:schedule, next_execution_at: Time.local(2000, 1, 1, 0, 1, 0))
      assert_nil schedule.grace_expires_at
      schedule.grace = "5m"
      assert_equal "2000-01-01 00:06:00", schedule.grace_expires_at.strftime("%Y-%m-%d %H:%M:%S")
    end

  end

  class Methods < ScheduleTest

    test ":reset! updates next_execution_at" do
      travel_to Time.local(2000, 1, 1, 0, 0, 0)
      schedule = create(:schedule)
      travel_back
      assert_changes "schedule.next_execution_at" do
        schedule.reset!
      end
    end

    test ":reset! updates grace_expires_at" do
      travel_to Time.local(2000, 1, 1, 0, 0, 0)
      schedule = create(:schedule)
      schedule.grace = "1m"
      travel_back
      assert_changes "schedule.grace_expires_at" do
        schedule.reset!
      end
    end

    test ":reset! false" do
      datetime = "2000-01-01 00:00:01"
      schedule = create(:schedule, expression: datetime, next_execution_at: datetime)
      assert_changes "schedule.next_execution_at", to: nil do
        schedule.reset!
      end
      assert schedule.expired?
    end

    test ":expired? false" do
      schedule = create(:schedule, grace_expires_at: nil, next_execution_at: Time.now + 1.minute)
      refute schedule.expired?
      assert_empty Schedule.expired
    end

    test ":expired? false grace" do
      schedule = create(:schedule, grace_expires_at: Time.now + 1.minute, next_execution_at: Time.now - 1.minute)
      refute schedule.expired?
      assert_empty Schedule.expired
    end

    # Note: Last execution but still within grace
    test ":expired? false grace nil next_execution_at" do
      schedule = create(:schedule, grace_expires_at: Time.now + 1.minute)
      schedule.update(next_execution_at: nil)
      refute schedule.expired?
      assert_empty Schedule.expired
    end

    test ":expired? true" do
      schedule = create(:schedule, grace_expires_at: nil, next_execution_at: Time.now - 1.minute)
      assert schedule.expired?
      assert Schedule.expired.first, schedule
    end

    test ":expired? true grace" do
      schedule = create(:schedule, grace_expires_at: Time.now - 1.minute, next_execution_at: Time.now - 2.minute)
      assert schedule.expired?
      assert Schedule.expired.first, schedule
    end

    test ":grace_expires_secs with :grace_expires_at nil" do
      schedule = build(:schedule, grace_expires_at: nil)
      assert_nil schedule.grace_expires_secs
    end

    test ":grace_expires_secs with :grace_expires_at" do
      travel_to Time.local(2000, 1, 1, 0, 0, 0)
      schedule = build(:schedule, grace_expires_at: Time.local(2000, 1, 1, 0, 1, 8))
      assert_equal 68, schedule.grace_expires_secs
    end

    test ":next_execution_secs with :next_execution_at nil" do
      schedule = build(:schedule, next_execution_at: nil)
      assert_nil schedule.next_execution_secs
    end

    test ":next_execution_secs with :next_execution_at" do
      travel_to Time.local(2000, 1, 1, 0, 0, 0)
      schedule = build(:schedule, next_execution_at: Time.local(2000, 1, 1, 0, 1, 8))
      assert_equal 68, schedule.next_execution_secs
    end

  end

end

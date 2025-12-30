require "test_helper"

class IntervalTest < ActiveSupport::TestCase

  class Validations < IntervalTest

    test "default valid" do
      assert build(:interval).valid?
    end

    test ":enabled nil is invalid" do
      assert_not build(:interval, enabled: nil).valid?
    end

    test ":name nil is invalid" do
      assert_not build(:interval, name: nil).valid?
    end

  end

  class Logic < IntervalTest

    test "destorying interval destroys schedules association" do
      interval = create(:interval)
      schedule = create(:schedule, target: interval)
      assert_equal schedule, interval.schedules.first
      interval.destroy
      assert_equal 0, Schedule.count
    end

  end

  class Methods < IntervalTest

    test ":impending creates execution" do
      interval = create(:interval)
      assert_empty interval.executions
      assert_changes "interval.executions.count" do
        interval.impending
      end
    end

  end

end

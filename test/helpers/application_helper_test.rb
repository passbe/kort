require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  class Timespan < ApplicationHelperTest
    test "nil" do
      assert_nil timespan(nil)
    end

    test "seconds" do
      assert_equal "0s", timespan(0)
      assert_equal "4s", timespan(4)
      assert_equal "58s", timespan(58)
    end

    test "minutes" do
      assert_equal "2m 2s", timespan(122)
      assert_equal "2m 22s", timespan(142)
    end

    test "hours" do
      assert_equal "128h 2m 22s", timespan(460942)
      assert_equal "120h 0m 0s", timespan(432000)
    end
  end
end

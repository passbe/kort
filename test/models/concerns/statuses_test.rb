require "test_helper"

class StatusesTest < ActiveSupport::TestCase

  class StatusesTestDummy < ActiveRecord::Base
    self.table_name = "executions"
    include Statuses
  end

  def setup
    @dummy = StatusesTestDummy.new
  end

  test ":set_status! __callee__" do
    StatusesTestDummy::STATUSES.each do |s|
      assert_equal s, @dummy.send("#{s}!").status
    end
  end

  test ":set_status! by value" do
    @dummy.set_status!("testing")
    assert_equal "testing", @dummy.status
  end

  test ":is_status? __callee__" do
    prev = nil
    StatusesTestDummy::STATUSES.each do |s|
      assert_not @dummy.send("#{s}?")
      @dummy.status = s
      assert @dummy.send("#{s}?")
      prev = s
    end
  end

end

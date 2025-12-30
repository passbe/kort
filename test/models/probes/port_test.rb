require "test_helper"

class Probes::PortTest < ActiveSupport::TestCase

  class Validations < Probes::PortTest

    test "default valid" do
      assert build(:probe_port).valid?
    end

    test ":setting_host nil is invalid" do
      assert_not build(:probe_port, host: nil).valid?
    end

    test ":setting_port nil is invalid" do
      assert_not build(:probe_port, port: nil).valid?
    end

    test ":setting_port non-integer is invalid" do
      assert_not build(:probe_port, port: "a").valid?
    end

    test ":setting_port must be in 1...65535, otherwise invalid" do
      assert_not build(:probe_port, port: 0).valid?
      assert_not build(:probe_port, port: -1).valid?
      assert_not build(:probe_port, port: 65536).valid?
    end

    test ":setting_timeout nil is invalid" do
      assert_not build(:probe_port, timeout: nil).valid?
    end

    test ":setting_timeout non-integer is invalid" do
      assert_not build(:probe_port, timeout: "a").valid?
    end

    test ":setting_timeout must be in 1...60, otherwise invalid" do
      assert_not build(:probe_port, timeout: 0).valid?
      assert_not build(:probe_port, timeout: -1).valid?
      assert_not build(:probe_port, timeout: 61).valid?
    end

  end

  class Logic < Probes::PortTest

    [:timeout].each do |field|
      test "#{field} has default value" do
        assert_not Probes::Port.new.send(field).blank?
      end
    end

  end

  class Methods < Probes::PortTest

    test ":evaluate success" do
      outcome, message = build(:probe_port, port: 123).evaluate(true)
      assert outcome
      assert_equal I18n.t("probe.port.evaluator.message.true", port: 123), message
    end

    test ":evaluate failure" do
      outcome, message = build(:probe_port, port: 123).evaluate(false)
      assert_not outcome
      assert_equal I18n.t("probe.port.evaluator.message.false", port: 123), message
    end

  end

end

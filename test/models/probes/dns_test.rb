require "test_helper"

class Probes::DnsTest < ActiveSupport::TestCase

  include Dnsruby

  class Validations < Probes::DnsTest

    test "default valid" do
      assert build(:probe_dns).valid?
    end

    test ":setting_host nil is invalid" do
      assert_not build(:probe_dns, host: nil).valid?
    end

    test ":setting_record nil is invalid" do
      assert_not build(:probe_dns, record: nil).valid?
    end

    test ":setting_nameserver nil is invalid" do
      assert_not build(:probe_dns, nameserver: nil).valid?
    end

    test ":setting_port nil is invalid" do
      assert_not build(:probe_dns, port: nil).valid?
    end

    test ":setting_port non-integer is invalid" do
      assert_not build(:probe_dns, port: "a").valid?
    end

    test ":setting_port must be > 0, otherwise invalid" do
      assert_not build(:probe_dns, port: -43).valid?
    end

    test ":setting_protocol not PROTOCOL" do
      assert_not build(:probe_dns, protocol: "UDP ").valid?
    end

  end

  class Logic < Probes::DnsTest

    [:nameserver, :port].each do |field|
      test "#{field} has default value" do
        assert_not Probes::Dns.new.send(field).blank?
      end
    end

  end

  class Methods < Probes::DnsTest

    test ":evaluate success" do
      obj = mock()
      obj.stubs(:is_a?).returns(true)
      obj.stubs(:rcode).returns("EXAMPLE")
      outcome, message = build(:probe_dns).evaluate(obj)
      assert outcome
      assert_equal I18n.t("probe.dns.evaluator.message", type: "EXAMPLE"), message
    end

    test ":evaluate failure" do
      obj = mock()
      obj.stubs(:is_a?).returns(false)
      obj.stubs(:class).returns("Dnsruby::ERROR_EXAMPLE")
      outcome, message = build(:probe_dns).evaluate(obj)
      assert_not outcome
      assert_equal I18n.t("probe.dns.evaluator.message", type: "ERROR_EXAMPLE"), message
    end

    test ":udp? true" do
      assert build(:probe_dns, protocol: "UDP").udp?
    end

    test ":udp? false" do
      assert_not build(:probe_dns, protocol: "TCP").udp?
    end

  end

end

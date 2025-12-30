require "test_helper"

class Probes::HttpTest < ActiveSupport::TestCase

  class Validations < Probes::HttpTest

    test "default valid" do
      assert build(:probe_http).valid?
    end

    test ":setting_url nil is invalid" do
      assert_not build(:probe_http, url: nil).valid?
    end

    test ":setting_method nil is invalid" do
      assert_not build(:probe_http, method: nil).valid?
    end

    test ":setting_method not PROTOCOL" do
      assert_not build(:probe_http, method: "GET ").valid?
    end

    test ":setting_timeout nil is invalid" do
      assert_not build(:probe_http, timeout: nil).valid?
    end

    test ":setting_timeout non-integer is invalid" do
      assert_not build(:probe_http, timeout: "a").valid?
    end

    test ":setting_timeout must be > 0, otherwise invalid" do
      assert_not build(:probe_http, timeout: -43).valid?
    end

    test ":setting_verify_ssl nil is invalid" do
      assert_not build(:probe_http, verify_ssl: nil).valid?
    end

    test ":setting_verify_ssl not boolean" do
      assert_not build(:probe_http, verify_ssl: "a").valid?
    end

    test ":setting_verify_ssl must be boolean" do
      assert build(:probe_http, verify_ssl: true).valid?
      assert build(:probe_http, verify_ssl: false).valid?
    end

    test ":setting_follow_redirect nil is invalid" do
      assert_not build(:probe_http, follow_redirect: nil).valid?
    end

    test ":setting_follow_redirect not boolean" do
      assert_not build(:probe_http, follow_redirect: "a").valid?
    end

    test ":setting_follow_redirect must be boolean" do
      assert build(:probe_http, follow_redirect: true).valid?
      assert build(:probe_http, follow_redirect: false).valid?
    end

  end

  class Logic < Probes::HttpTest

    [:method, :timeout, :follow_redirect, :verify_ssl].each do |field|
      test "#{field} has default value" do
        assert_not Probes::Http.new.send(field).blank?
      end
    end

  end

  class Methods < Probes::HttpTest

    test ":evaluate success" do
      obj = mock()
      obj.stubs(:is_a?).returns(true)
      obj.stubs(:code).returns(200)
      outcome, message = build(:probe_http).evaluate(obj)
      assert outcome
      assert_equal I18n.t("probe.http.evaluator.message.true"), message
    end

    test ":evaluate failure by class" do
      obj = mock()
      obj.stubs(:is_a?).returns(false)
      obj.stubs(:code).returns(200)
      outcome, message = build(:probe_http).evaluate(obj)
      assert_not outcome
      assert_equal I18n.t("probe.http.evaluator.message.false"), message
    end

    test ":evaluate failure by status" do
      obj = mock()
      obj.stubs(:is_a?).returns(true)
      obj.stubs(:code).returns(300)
      outcome, message = build(:probe_http).evaluate(obj)
      assert_not outcome
      assert_equal I18n.t("probe.http.evaluator.message.false"), message
    end

  end

end

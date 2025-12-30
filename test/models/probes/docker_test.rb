require "test_helper"

class Probes::DockerTest < ActiveSupport::TestCase

  class Validations < Probes::DockerTest

    test "default valid" do
      assert build(:probe_docker).valid?
    end

    test ":setting_path nil is invalid" do
      assert_not build(:probe_docker, path: nil).valid?
    end

    test ":setting_reference nil is invalid" do
      assert_not build(:probe_docker, reference: nil).valid?
    end

  end

  class Methods < Probes::DockerTest

    test ":evaluate success" do
      obj = { "State": { "Running": true }, "Name": "EXAMPLE" }.deep_stringify_keys
      outcome, message = build(:probe_docker).evaluate(obj)
      assert outcome
      assert_equal I18n.t("probe.docker.evaluator.message.true", reference: "EXAMPLE"), message
    end

    test ":evaluate failure" do
      obj = { "State": { "Running": false }, "Name": "ERROR_EXAMPLE" }.deep_stringify_keys
      outcome, message = build(:probe_docker).evaluate(obj)
      assert_not outcome
      assert_equal I18n.t("probe.docker.evaluator.message.false", reference: "ERROR_EXAMPLE"), message
    end

  end

end

require "test_helper"

# Note: Was unable to get a separate class to work for this concern testing
class StoreCastingTest < ActiveSupport::TestCase

  test ":store_accessor_integer getter" do
    probe = build(:probe_port)
    probe.settings["port"] = "123"
    assert_instance_of String, probe.settings["port"]
    assert_equal 123, probe.port
  end

  test ":store_accessor_integer setter" do
    probe = build(:probe_port, port: nil)
    probe.port = "123"
    assert_instance_of Integer, probe.settings["port"]
  end

  test ":store_accessor_boolean getter" do
    probe = build(:probe_http)
    probe.settings["verify_ssl"] = "1"
    assert_instance_of String, probe.settings["verify_ssl"]
    assert probe.verify_ssl
    probe.settings["verify_ssl"] = "0"
    assert_instance_of String, probe.settings["verify_ssl"]
    refute probe.verify_ssl
  end

  test ":store_accessor_boolean setter" do
    probe = build(:probe_http, verify_ssl: nil)
    probe.verify_ssl = "1"
    assert_instance_of TrueClass, probe.settings["verify_ssl"]
    probe.verify_ssl = "0"
    assert_instance_of FalseClass, probe.settings["verify_ssl"]
    probe.verify_ssl = "A"
    assert_instance_of String, probe.settings["verify_ssl"]
  end

  test ":store_accessor_hash getter" do
    probe = build(:probe_http)
    probe.settings["headers"] = "User-Agent = Test\n  Header = Value  "
    assert_instance_of String, probe.settings["headers"]
    assert_instance_of Hash, probe.headers
    hash = { "User-Agent": "Test", "Header": "Value" }.stringify_keys
    assert_equal hash, probe.headers
  end

  test ":store_accessor_hash setter" do
    probe = build(:probe_http)
    probe.headers = "User-Agent = Te\\=st\n  Header = Value  "
    assert_instance_of Hash, probe.settings["headers"]
    hash = { "User-Agent": "Te=st", "Header": "Value" }.stringify_keys
    assert_equal hash, probe.headers
  end

end

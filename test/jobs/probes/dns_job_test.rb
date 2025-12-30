require "test_helper"

class Probes::DnsJobTest < ActiveJob::TestCase

  test "constructs Dnsruby::Resolver" do
    execution = build(:execution, target: create(:probe_dns))
    Dnsruby::Resolver.any_instance.expects(:initialize).with({
      nameserver: execution.probe.nameserver,
      port: execution.probe.port,
      do_caching: false,
      use_tcp: false
    })
    Dnsruby::Resolver.any_instance.stubs(:query).returns(Dnsruby::Message.new)
    Probes::DnsJob.perform_now(execution, nil)
  end

  test "executes Dnsruby::Resolver.query" do
    execution = build(:execution, target: create(:probe_dns))
    Dnsruby::Resolver.any_instance.expects(:query).with(
      execution.probe.host,
      execution.probe.record
    ).returns(Dnsruby::Message.new)
    assert_instance_of Dnsruby::Message, Probes::DnsJob.perform_now(execution, nil)
  end

  test "catches Dnsruby::ResolvError" do
    execution = build(:execution, target: create(:probe_dns))
    Dnsruby::Resolver.any_instance.expects(:query).with(
      execution.probe.host,
      execution.probe.record
    ).raises(Dnsruby::NXDomain)
    assert_instance_of Dnsruby::NXDomain, Probes::DnsJob.perform_now(execution, nil)
  end

end

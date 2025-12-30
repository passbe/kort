class Probes::DnsJob < ProbeJob

  include Dnsruby

  def perform(execution, schedule)
    raise "probe must be of class type Probes::Dns" unless execution.probe.is_a?(Probes::Dns)
    # Create resolver to target namserver
    resolver = Resolver.new({
      nameserver: execution.probe.nameserver,
      port: execution.probe.port,
      do_caching: false,
      use_tcp: !execution.probe.udp?
    })
    # Query
    begin
      answer = resolver.query(execution.probe.host, execution.probe.record)
      execution.info ""
      execution.info "Answer"
      execution.info "------"
      execution.info answer
      answer
    # We catch this error just to return a fake object back to make a pretty error message
    rescue ResolvError => e
      e
    end
  end

end

class Probes::PortJob < ProbeJob

  def perform(execution, schedule)
    raise "probe must be of class type Probes::Port" unless execution.probe.is_a?(Probes::Port)
    Timeout.timeout(execution.probe.timeout) do
      TCPSocket.new(execution.probe.host, execution.probe.port).close
      true
    end
  rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ENETUNREACH, Timeout::Error
    false
  end

end

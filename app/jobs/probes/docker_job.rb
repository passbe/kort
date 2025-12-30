class Probes::DockerJob < ProbeJob

  def perform(execution, schedule)
    raise "probe must be of class type Probes::Docker" unless execution.probe.is_a?(Probes::Docker)

    # Retrieve container
    info = Docker::Container.get(
      execution.probe.reference,
      Docker::Connection.new(execution.probe.path, {})
    ).json
    execution.info JSON.pretty_generate(info)
    info
  end

end

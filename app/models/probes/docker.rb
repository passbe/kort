class Probes::Docker < Probe

  # Path (socket or API)
  store_accessor :settings, :path
  validates :path, presence: true

  # Reference (id or name)
  store_accessor :settings, :reference
  validates :reference, presence: true

  # Default evaluator - running must be true
  def evaluate(result)
    success = result.dig("State", "Running")
    hostname = result.dig("Name") || result.dig("ID") || I18n.t("unknown")
    return success,
      I18n.t("probe.docker.evaluator.message.#{success}", reference: hostname)
  end

end

class Probes::Port < Probe

  after_initialize :set_defaults, if: :new_record?

  # Target to check
  store_accessor :settings, :host
  validates :host, presence: true

  # Port to check
  store_accessor_integer :settings, :port
  validates :port, numericality: {
    only_integer: true,
    in: 1..65535
  }

  # Timeout
  store_accessor_integer :settings, :timeout
  validates :timeout, numericality: {
    only_integer: true,
    in: 1..60
  }

  # Default evaluate - if we do not receive an error = success
  def evaluate(result)
    return result,
      I18n.t("probe.port.evaluator.message.#{result}", port: port)
  end

  private

  def set_defaults
    self.timeout = 3
  end

end

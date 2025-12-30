class Probes::Dns < Probe

  include Dnsruby

  PROTOCOLS = %w[UDP TCP]

  after_initialize :set_defaults, if: :new_record?

  # Target to resolve
  store_accessor :settings, :host
  validates :host, presence: true

  # Record type to resolve
  store_accessor :settings, :record
  validates :record, inclusion: {
    in: Dnsruby::Types.strings
  }

  # Nameserver to resolve
  store_accessor :settings, :nameserver
  validates :nameserver, presence: true

  # Port to use against nameserver
  store_accessor_integer :settings, :port
  validates :port, numericality: {
    only_integer: true,
    greater_than: 0
  }

  # Protocol to use against nameserver
  store_accessor :settings, :protocol
  validates :protocol, inclusion: {
    in: PROTOCOLS
  }

  # Default evaluate - if we do not receive an error = success
  def evaluate(result)
    code = result.is_a?(Dnsruby::Message) ?
      result.rcode : result.class.to_s.split("::").last
    return result.is_a?(Dnsruby::Message),
    I18n.t("probe.dns.evaluator.message", type: code)
  end

  # Are we using UDP?
  def udp?
    self.protocol == PROTOCOLS.first
  end

  private

  def set_defaults
    self.port = 53
    self.nameserver = "1.1.1.1"
    self.protocol = PROTOCOLS.first
  end

end

class Probes::Http < Probe

  after_initialize :set_defaults, if: :new_record?

  # URL
  store_accessor :settings, :url
  validates :url, presence: true

  # Method type for request
  store_accessor :settings, :method
  validates :method, inclusion: {
    in: HTTP::Request::METHODS.map { _1.to_s.upcase }
  }

  # Timeout
  store_accessor_integer :settings, :timeout
  validates :timeout, numericality: {
    only_integer: true,
    in: 1..60
  }

  # Verify SSL
  store_accessor_boolean :settings, :verify_ssl
  validates :verify_ssl, inclusion: {
    in: [true, false]
  }

  # Follow Redirection
  store_accessor_boolean :settings, :follow_redirect
  validates :follow_redirect, inclusion: {
    in: [true, false]
  }

  # Body
  store_accessor :settings, :body

  # Headers
  store_accessor_hash :settings, :headers

  # Default evaluate - status code 200 <> 299 success
  def evaluate(result)
    success = (result.is_a?(HTTP::Response) and result.code < 300)
    return success,
      I18n.t("probe.http.evaluator.message.#{success}")
  end

  private

  def set_defaults
    self.method = "GET"
    self.timeout = 10
    self.verify_ssl = true
    self.follow_redirect = true
  end

end

class Probes::HttpJob < ProbeJob

  def perform(execution, schedule)
    raise "probe must be of class type Probes::Http" unless execution.probe.is_a?(Probes::Http)

    # Setup HTTP Client Options
    options = {}.tap do |opts|
      # Setup redirect
      opts[:follow] = execution.probe.follow_redirect

      # Setup timeout
      opts[:timeout_class] = HTTP::Timeout::Global
      opts[:timeout_options] = { global_timeout: execution.probe.timeout }

      # Setup headers
      opts[:headers] = HTTP::Headers.new.merge(execution.probe.headers) if
        execution.probe.headers.present?

      # Setup no verify
      if !execution.probe.verify_ssl
        ctx = OpenSSL::SSL::SSLContext.new
        ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
        opts[:ssl_context] = ctx
      end
    end

    # Setup client with options + logging
    client = HTTP::Client.new(options).use(
      logging: {
        logger: execution
      }
    )

    # Fire request
    client.request(
      execution.probe.method,
      execution.probe.url,
      {
        body: execution.probe.body
      }
    )
  end

end

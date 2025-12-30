require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Kort
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Prefer to UUID primary key but with sqlite that must be string
    config.generators do |g|
       g.orm :active_record, primary_key_type: :string
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = ENV["TZ"] || "UTC"

    # Executor repeating seconds
    config.executor_seconds = 5

    # Number of months to keep execution retention 1..12
    config.retention_months = 6 # Default
    if ENV.has_key?("RETENTION_MONTHS")
      config.retention_months = ENV["RETENTION_MONTHS"].to_i
    end
    raise "Retention Months is configured outside of the allowable range from 1 to 12" unless (1..12).cover?(config.retention_months)
  end
end

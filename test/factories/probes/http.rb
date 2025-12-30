FactoryBot.define do
  factory :probe_http, parent: :probe, class: Probes::Http do
    type { "Probes::Http" }
    url { "google.com" }
    add_attribute(:method) { "GET" } # Factory Bot reserved word
    timeout { 10 }
    verify_ssl { true }
    follow_redirect { true }
    headers { }
    body { }
  end
end

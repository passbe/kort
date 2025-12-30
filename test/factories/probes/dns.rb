FactoryBot.define do
  factory :probe_dns, parent: :probe, class: Probes::Dns do
    type { "Probes::Dns" }
    host { "google.com" }
    record { "A" }
    nameserver { "1.1.1.1" }
    port { 53 }
    protocol { "UDP" }
  end
end

FactoryBot.define do
  factory :probe_port, parent: :probe, class: Probes::Port do
    type { "Probes::Port" }
    host { "127.0.0.1" }
    port { 80 }
    timeout { 1 }
  end
end

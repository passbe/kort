FactoryBot.define do
  factory :probe do
    enabled { true }
    sequence(:name) { |n| "Probe #{n}" }
    description { nil }
    tag_list { nil }
    # Must have a valid class here - defaulting to DNS
    type { "Probes::Dns" }
    settings { {} }
    evaluator { nil }
  end
end

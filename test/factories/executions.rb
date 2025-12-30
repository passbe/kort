FactoryBot.define do
  factory :execution do
    target { build(:probe_dns) }
    schedule { build(:schedule) }
    status { Execution::Status::PENDING }
    log_identifier { SecureRandom.uuid }
    message { nil }
    started_at { nil }
    finished_at { nil }
    counter { nil }
  end
end

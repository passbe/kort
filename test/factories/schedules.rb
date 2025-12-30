FactoryBot.define do
  factory :schedule do
    expression { "*-*-* 10:00:00" }
    next_execution_at { Time.zone.tomorrow.at_beginning_of_day.advance(hours: 10) }
    grace { nil }
    grace_expires_at { nil }
    target { build(:probe_dns) }
  end
end

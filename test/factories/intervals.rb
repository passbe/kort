FactoryBot.define do
  factory :interval do
    enabled { true }
    sequence(:name) { |n| "Interval #{n}" }
    description { nil }
    tag_list { nil }
    evaluator { nil }
  end
end

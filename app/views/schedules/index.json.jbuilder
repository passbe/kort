json.pagination do
  json.extract! @pagy, :page, :limit
  json.total @pagy.count
  json.count @pagy.in
end
json.data do
  json.array! @schedules, partial: "schedules/schedule", as: :schedule
end

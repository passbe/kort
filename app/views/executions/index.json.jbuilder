json.pagination do
  json.extract! @pagy, :page, :limit
  json.total @pagy.count
  json.count @pagy.in
end
json.data do
  json.array! @executions, partial: "executions/execution", as: :execution
end

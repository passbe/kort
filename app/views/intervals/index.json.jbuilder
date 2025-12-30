json.pagination do
  json.extract! @pagy, :page, :limit
  json.total @pagy.count
  json.count @pagy.in
end
json.data do
  json.array! @intervals, partial: "intervals/interval", as: :interval
end

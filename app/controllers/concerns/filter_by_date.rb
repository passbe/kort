module FilterByDate
  extend ActiveSupport::Concern

  DAY_FORMAT = "%Y-%m-%d"
  MONTH_FORMAT = "%Y-%m"

  # Returns a new query with the relevant where clause by field
  # - Day: Returns query where field between start and end of day
  # - Month: Returns query where field between start of month and end of month
  # returns [ query object , date object || nil , mode sym || nil ]
  def filter_by_date(query, field: :created_at)
    # Prioritise day over month
    if params.has_key?(:day)
      filter_by_day(query, field, params[:day]).append(:day)
    elsif params.has_key?(:month)
      filter_by_month(query, field, params[:month]).append(:month)
    else
      [query, nil, nil]
    end
  rescue Date::Error
    [query, nil, nil]
  end

  def filter_by_day(query, field, day_str)
    day = Date.strptime(day_str, DAY_FORMAT)
    [query.where(field => day.all_day), day]
  end

  def filter_by_month(query, field, month_str)
    month = Date.strptime(month_str, MONTH_FORMAT)
    [query.where(field => month.all_month), month]
  end
end

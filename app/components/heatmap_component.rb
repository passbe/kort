class HeatmapComponent < ViewComponent::Base

  def initialize(target: nil, months: 6)
    @target = target
    # Note: For the UI we don't want more than 12 months
    #       At the time of writing we hardcode a 12 limit in the config but I can see that
    #       maybe changing in future.
    @months = (months > 12) ? 12 : months
  end

  def generate_series
    cursor = (Time.now - (@months - 1).months).beginning_of_month
    # Note: We don't let SQL group here because of timezone support
    records = ((@target.nil?) ? Execution : @target.executions)
      .where("created_at >= ?", cursor)
      .pluck(:created_at, :status)

    # Lets create series to fill
    series = {}
    (cursor.to_date..Date.today).each do |date|
      m = date.strftime("%Y-%m")
      series[m] = {} unless series.has_key?(m)
      series[m][date.strftime("%Y-%m-%d")] = []
    end

    # Insert records into correct position
    records.each do |record|
      series[record.first.strftime("%Y-%m")][record.first.strftime("%Y-%m-%d")] << record.last
    end
    series
  end

  def path(**args)
    case @target
    when Probe
      probe_path(@target, **args)
    when Interval
      interval_path(@target, **args)
    when nil
      root_path(**args)
    end
  end

  def status_css(statuses)
    if statuses.include?(Execution::Status::FAILURE)
      "bg-red-400"
    elsif statuses.include?(Execution::Status::WARNING)
      "bg-yellow-400"
    elsif statuses.include?(Execution::Status::SKIPPED)
      "bg-indigo-400"
    elsif statuses.include?(Execution::Status::SUCCESS)
      "bg-green-400"
    elsif statuses.include?(Execution::Status::PENDING) or statuses.include?(Execution::Status::STARTED)
      "bg-zinc-500"
    end
  end

end

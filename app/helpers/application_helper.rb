module ApplicationHelper
  def timespan(total)
    return nil if total.nil?
    hours = total / 3600
    remaining = total % 3600
    minutes = remaining / 60
    seconds = remaining % 60
    # Build string
    parts = []
    parts << "#{hours}h" if hours > 0
    parts << "#{minutes}m" if !parts.empty? or minutes > 0
    parts << "#{seconds}s"
    parts.join(" ")
  end

  def status_bg_css(target)
    case target
    when true, Execution::Status::SUCCESS
      "bg-green-400"
    when false, Execution::Status::WARNING
      "bg-yellow-400"
    when Execution::Status::STARTED, Execution::Status::PENDING
      "bg-zinc-400"
    when Execution::Status::FAILURE
      "bg-red-400"
    when Execution::Status::SKIPPED
      "bg-indigo-400"
    end
  end
end

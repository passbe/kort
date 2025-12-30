class ExecutionComponent < ViewComponent::Base

  with_collection_parameter :execution

  def initialize(execution:, variant: :detailed)
    @execution = execution
    @variant = variant
  end

  def detailed?
    @variant == :detailed
  end

  def summary?
    @variant == :summary
  end

  def path(**args)
    case @execution.target
    when Probe
      probe_path(@execution.target, **args)
    when Interval
      interval_path(@execution.target, **args)
    end
  end

  def timer_html_data
    if @execution.started? and !@execution.started_at.nil? and @execution.finished_at.nil?
      {
        controller: "timer",
        "timer-time-value": @execution.started_at.to_i
      }
    else
      {}
    end
  end

  def link_css
    "px-2 lg:px-4 py-2 block w-full h-full no-underline! hover:text-gray-300!"
  end

  def status_css
    [
      "px-2 lg:px-4 py-2 block w-full h-full no-underline!",
      {
        "text-zinc-400! hover:text-zinc-400!": (@execution.pending? or @execution.started?),
        "text-green-400! hover:text-green-400!": @execution.success?,
        "text-red-400! hover:text-red-400!": @execution.failure?,
        "text-yellow-400! hover:text-yellow-400!": @execution.warning?,
        "text-indigo-400! hover:text-indigo-400!": @execution.skipped?
      }
    ]
  end

end

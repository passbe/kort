class ExecutionsController < ApplicationController

  include FilterByDate

  before_action :set_execution, only: %i[ show download_log ]

  def index
    query, @date, @mode = filter_by_date(Execution.all)
    @pagy, @executions = pagy(query.includes(:target))
    @probe_count = Probe.count
    @interval_count = Interval.count
  end

  def show
    @next_execution = @execution.next_by_created_at
    @previous_execution = @execution.previous_by_created_at
    respond_to do |format|
      format.html {
        render @execution.target.is_a?(Probe) ? "show-probe" : "show-interval"
      }
      format.json { render "show" }
    end
  end

  def download_log
    send_file @execution.log_file,
      filename: @execution.log_file.basename.to_s,
      type: "application/text",
      disposition: "attachment"
  end

  private

  def set_execution
    @execution = Execution.find(params.expect(:id))
  end

end

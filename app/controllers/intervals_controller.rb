class IntervalsController < ApplicationController

  include FilterByDate

  skip_before_action :verify_authenticity_token, only: %i[ signal start log ]
  before_action :set_interval, only: %i[ show signal start log edit update confirm destroy ]
  before_action :current_execution, only: %i[ signal start log ]

  def index
    @execution_count = Execution.where(target_type: Interval.model_name.human).count
    @pagy, @intervals = pagy(Interval.all)
  end

  def show
    query, @date, @mode = filter_by_date(@interval.executions)
    @pagy, @executions = pagy(query)
    @next_schedule = @interval.next_schedule
    @current_grace_schedule = @interval.current_grace_schedule
  end

  def signal
    if @execution
      @execution.status = params.dig(:status) || Execution::Status::SUCCESS
      @execution.message = params.dig(:message)
      @execution.finished_at = Time.now
      if @execution.save
        @execution.info I18n.t("interval.signal.message", message: @execution.message) unless @execution.message.blank?
        @execution.log_by_status I18n.t("interval.signal.ping_log", status: @execution.status, ip: request.remote_ip)
        @execution.schedule.reset!
        render plain: I18n.t("interval.signal.ping",
          status: @execution.status,
          time: @execution.finished_at,
          id: @execution.id,
          counter: @execution.counter,
          name: @interval.name
        ), status: :ok
      else
        render plain: @execution.errors.full_messages.join("\n"), status: :bad_request
      end
    else
      render plain: I18n.t("interval.signal.no_execution",
        name: @interval.name), status: :bad_request
    end
  end

  def start
    if @execution
      @execution.started_at = Time.now
      @execution.started!
      if @execution.save
        @execution.info I18n.t("interval.signal.start_log", ip: request.remote_ip)
        render plain: I18n.t("interval.signal.start",
          time: @execution.started_at,
          id: @execution.id,
          counter: @execution.counter,
          name: @interval.name
        ), status: :ok
      else
        render plain: @execution.errors.full_messages.join("\n"), status: :bad_request
      end
    else
      render plain: I18n.t("interval.signal.no_execution",
        name: @interval.name), status: :bad_request
    end
  end

  def log
    if @execution
      request.body.each_line do |line|
        line = line.chomp
        @execution.log_by_level(line.chomp, params.dig(:level)) unless line.empty?
      end
    else
      render plain: I18n.t("interval.signal.no_execution",
        name: @interval.name), status: :bad_request
    end
  end

  def new
    @interval = Interval.new(enabled: true)
  end

  def edit
  end

  def create
    @interval = Interval.new(interval_params)

    respond_to do |format|
      if @interval.save
        format.html { redirect_to interval_path(@interval) }
        format.json { render :show, status: :created, location: @interval }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @interval.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @interval.update(interval_params)
        format.html { redirect_to interval_path(@interval) }
        format.json { render :show, status: :ok, location: @interval }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @interval.errors, status: :unprocessable_entity }
      end
    end
  end

  def confirm
  end

  def destroy
    @interval.destroy!

    respond_to do |format|
      format.html { redirect_to intervals_path, status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_interval
    @interval = Interval.find(params.expect(:id))
  end

  # Get latest pending || started execution
  def current_execution
    @execution = @interval.executions.where(status: [Execution::Status::PENDING, Execution::Status::STARTED]).first
  end

  def interval_params
    params.expect(interval: [
      :enabled,
      :name,
      :description,
      :tag_list,
      :evaluator,
      schedules_attributes: [[:id, :expression, :grace, :_destroy]]
    ])
  end

end

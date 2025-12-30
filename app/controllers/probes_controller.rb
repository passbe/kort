class ProbesController < ApplicationController

  include FilterByDate

  before_action :set_probe, only: %i[ show edit update execute confirm destroy ]

  def index
    @execution_count = Execution.where(target_type: Probe.model_name.human).count
    @pagy, @probes = pagy(Probe.all)
  end

  def show
    query, @date, @mode = filter_by_date(@probe.executions)
    @pagy, @executions = pagy(query)
    @next_schedule = @probe.next_schedule
  end

  def new
    @probe = Probe.new(enabled: true)
  end

  def fields
    begin
      @probe = Probe.new(type: Probe.type_class(params.dig(:type)))
      render :fields
    rescue ActiveRecord::SubclassNotFound, NameError
      render plain: "", status: :unprocessable_entity
    end
  end

  def edit
  end

  def create
    begin
      # New probe with desired type class so our methods are setup to accept all attributes
      @probe = Probe.new(type: probe_params.dig(:type))
      # Now lets add all the attributes we need
      @probe.assign_attributes(probe_params(settings: @probe.class.stored_attributes[:settings]))
    rescue ActiveRecord::SubclassNotFound, NameError
      @probe = Probe.new(probe_params.except(:type))
    end

    respond_to do |format|
      if @probe.save
        format.html { redirect_to probe_path(@probe) }
        format.json { render :show, status: :created, location: @probe }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @probe.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @probe.update(probe_params(settings: @probe.class.stored_attributes[:settings]))
        format.html { redirect_to probe_path(@probe) }
        format.json { render :show, status: :ok, location: @probe }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @probe.errors, status: :unprocessable_entity }
      end
    end
  end

  def execute
    if @probe.enabled
      redirect_to execution_path(@probe.execute)
    else
      redirect_to probe_path(@probe)
    end
  end

  def confirm
  end

  def destroy
    @probe.destroy!

    respond_to do |format|
      format.html { redirect_to probes_path, status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_probe
    @probe = Probe.find(params.expect(:id))
  end

  def probe_params(settings: [])
    params.expect(probe: [
      :enabled,
      :name,
      :description,
      :tag_list,
      :type,
      :evaluator,
      schedules_attributes: [[:id, :expression, :_destroy]]
    ].concat(settings || []))
  end

end

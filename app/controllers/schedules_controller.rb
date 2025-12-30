class SchedulesController < ApplicationController

  before_action :build_schedule, only: %i[ validate create ]
  before_action :set_schedule, only: %i[ show ]

  def index
    @pagy, @schedules = pagy(Schedule.all)
    respond_to do |format|
      format.html {
        redirect_to root_path
      }
      format.json { render "index" }
    end
  end

  def show
    respond_to do |format|
      format.html {
        redirect_to root_path
      }
      format.json { render "show" }
    end
  end

  def validate
  end

  def create
  end

  private

  def build_schedule
    @schedule = Schedule.new(schedule_params)
    @klass = @schedule.target_type_base_class.name.downcase
    # Note: At this stage only probes do not support grace in schedules
    @without_grace = (@klass == "probe")
  end

  def schedule_params
    params.expect(schedule: [
      :expression,
      :grace,
      :target_type,
      :target_id
    ])
  end

  def set_schedule
    @schedule = Schedule.find(params.expect(:id))
  end

end

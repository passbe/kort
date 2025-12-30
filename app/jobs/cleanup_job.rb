class CleanupJob < ApplicationJob

  queue_as :system

  def perform(retention_months: Rails.application.config.retention_months)
    # Destroy executions older than retention_months
    Execution.where("created_at <= ?", Time.now - retention_months.months).destroy_all
    # Clean-up earlier months folder if empty (skip current month)
    # Note: We go back last 24 because a) it can't hurt b) in case system has been off for a while or change in retention
    (1..24).each do |i|
      folder = Rails.root.join(
        "storage",
        "logs",
        (Time.now - i.months).strftime("%Y-%m")
      )
      folder.rmdir if folder.exist? and folder.empty?
    end
  end

end

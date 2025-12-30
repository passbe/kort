class CreateSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :schedules, id: :string do |t|
      t.string :expression, null: false
      t.datetime :next_execution_at, null: true
      t.string :grace, null: true
      t.datetime :grace_expires_at, null: true
      t.references :target, polymorphic: true, null: false, type: :string
    end

    add_index :schedules, :next_execution_at, order: { next_execution_at: :desc }
  end
end

class CreateIntervals < ActiveRecord::Migration[8.0]
  def change
    create_table :intervals, id: :string do |t|
      t.boolean :enabled
      t.string :name, null: false
      t.string :description, null: true
      t.blob :evaluator, null: true
      t.integer :schedules_count, default: 0, null: false
      t.timestamps
    end
  end
end

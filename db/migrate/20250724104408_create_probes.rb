class CreateProbes < ActiveRecord::Migration[8.0]
  def change
    create_table :probes, id: :string  do |t|
      t.boolean :enabled
      t.string :name, null: false
      t.string :description, null: true
      t.string :type, null: false
      t.json :settings, null: true
      t.integer :schedules_count, default: 0, null: false
      t.blob :evaluator, null: true
      t.timestamps
    end
  end
end

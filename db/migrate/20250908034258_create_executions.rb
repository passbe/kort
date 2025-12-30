class CreateExecutions < ActiveRecord::Migration[8.0]
  def change
    create_table :executions, id: :string do |t|
      t.references :target, polymorphic: true, null: false, type: :string
      t.references :schedule, null: true, type: :string
      t.string :status, null: false
      t.string :log_identifier, null: false
      t.string :message
      t.json :details, null: true
      t.datetime :started_at, null: true
      t.datetime :finished_at, null: true
      t.integer :counter, null: false
      t.timestamps
    end
  end
end

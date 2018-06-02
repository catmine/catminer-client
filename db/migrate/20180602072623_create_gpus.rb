class CreateGpus < ActiveRecord::Migration[5.1]
  def change
    create_table :gpus do |t|
      t.string :name
      t.references :rig, foreign_key: true
      t.integer :brand
      t.string :uuid
      t.float :memory
      t.float :utilization
      t.float :power
      t.float :temperature
      t.float :fan
      t.float :memory_used
      t.float :power_limit
      t.integer :mem_clock
      t.integer :gpu_clock
      t.boolean :enabled, default: false

      t.timestamps
    end
  end
end

class CreateMiningLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :mining_logs do |t|
      t.references :rig, foreign_key: true
      t.text :line
      t.boolean :reported, default: false

      t.timestamps
    end
  end
end

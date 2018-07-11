class CreateCommands < ActiveRecord::Migration[5.1]
  def change
    create_table :commands do |t|
      t.references :rig, foreign_key: true
      t.integer :command_id
      t.integer :code
      t.string :args
      t.boolean :executed, default: false
      t.datetime :executed_at
      t.boolean :reported, default: false

      t.timestamps
    end
  end
end

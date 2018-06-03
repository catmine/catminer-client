class CreateMinings < ActiveRecord::Migration[5.1]
  def change
    create_table :minings do |t|
      t.references :rig, foreign_key: true
      t.integer :code
      t.integer :miner
      t.text :arg

      t.timestamps
    end
  end
end

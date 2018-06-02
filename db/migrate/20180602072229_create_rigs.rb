class CreateRigs < ActiveRecord::Migration[5.1]
  def change
    create_table :rigs do |t|
      t.string :name
      t.string :uuid
      t.string :secret
      t.string :pid

      t.timestamps
    end
  end
end

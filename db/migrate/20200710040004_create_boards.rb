class CreateBoards < ActiveRecord::Migration[6.0]
  def change
    create_table :boards do |t|
      t.integer :height
      t.integer :width
      t.text :board
      t.timestamps
    end
  end
end

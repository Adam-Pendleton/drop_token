class CreateMoves < ActiveRecord::Migration[6.0]
  def change
    create_table :moves do |t|
      t.references :game
      t.references :player
      t.string :kind
      t.integer :column
      t.integer :move_number
      t.timestamps
    end
  end
end

class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.boolean :completed, :default => false
      t.string :code
      t.references :winner, foreign_key: {to_table: :players}, :optional => true
      t.references :board, :optional => true
      t.timestamps
    end
  end
end

class CreateJoinTableGamePlayer < ActiveRecord::Migration[6.0]
  def change
    create_table :game_players do |t|
      t.string :active, :default => true
      t.references :game
      t.references :player
      t.index [:game_id, :player_id]
      t.index [:player_id, :game_id]
    end
  end
end

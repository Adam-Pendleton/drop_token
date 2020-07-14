class Player < ApplicationRecord
  has_many :game_players
  has_many :games, :through => :game_players
  
  def self.get_or_create_player(username)
    player = find_by(:username => username)
    if player.nil?
      player = create(:username => username)
    end
    return player
  end

  def quit_game!(game)
    game_player = game_players.find_by(:game => game)
    game_player.update!(:active => false)
  end
end

class Move < ApplicationRecord
  belongs_to :game
  belongs_to :player

  validates :column, :numericality => {
      :only_integer => true,
      :greater_than_or_equal_to => 0
  }, :if => Proc.new{ |move| move.kind == 'MOVE' }
  validate :column_must_be_in_bounds, :if => Proc.new{ |move| move.kind == 'MOVE' }
  validate :player_must_be_in_game
  validates :kind, :presence => true, :inclusion => { :in => ['MOVE', 'QUIT'] }
  validates :move_number, :presence => true, :numericality => { :only_integer => true }

  before_validation :set_move_number, :if => Proc.new{ |move| move.move_number.nil? }

  def to_hash
    hash = {
        'type': kind,
        'player': player.username,
    }
    if column.present?
      hash['column'] = column
    end
    hash
  end

  private
  
  def set_move_number
    self.move_number = game.moves.count
  end

  def column_must_be_in_bounds
    if column >= game.board.width || column < 0
      errors.add(:column, "Column must be less than number of columns in game")
    end
  end

  def player_must_be_in_game
    unless game.players.include? player
      errors.add(:player, "Player must be in the game")
    end
  end
end

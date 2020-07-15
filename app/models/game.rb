class Game < ApplicationRecord
  MIN_PLAYER_COUNT = 2
  MAX_PLAYER_COUNT = 2

  has_many :game_players
  has_many :players, :through => :game_players
  has_many :moves, :dependent => :destroy
  belongs_to :winner, :class_name => 'Player', :optional => true
  belongs_to :board, :optional => true, :dependent => :destroy

  validates_uniqueness_of :code, :allow_nil => true

  after_save :generate_code, :if => Proc.new{ |game| game.code.nil? }

  scope :in_progress, -> { where(:completed => false) }

  def self.start_new(players, rows, cols)
    board = Board.create(:height => rows, :width => cols)
    Game.create(:players => players, :board => board, :winner => nil)
  end

  def active_player?(player)
    return false if self.players.exclude? player
    game_player = self.game_players.find_by(:player => player)
    game_player.active?
  end

  def next_player
    #this needs restructuring for a 3+ player game
    if moves.blank?
      return players.first
    end
    (players - [moves.last.player]).first
  end

  def legal_move?(column)
    board.legal_move?(column)
  end

  def make_move!(player, column)
    move = nil
    ActiveRecord::Base.transaction do
      move = moves.create(:kind => 'MOVE', :player => player, :column => column)
      board.add_token!(player, column)
      if board.winning_move?(column)
        player_win!(player)
      end
      if board.draw?
        draw!
      end
    end
    move
  end

  def player_quit!(player)
    return false unless active_player?(player)

    ActiveRecord::Base.transaction do
      moves.create(:kind => 'QUIT', :player => player)
      player.quit_game!(self)
    end
    check_win_by_forfeit!
  end

  def check_win_by_forfeit!
    active_game_players = game_players.where(:active => true)
    if active_game_players.count == 1
      player_win!(active_game_players.last.player)
    end
  end

  def player_win!(player)
    update!(:winner => player, :completed => true)
  end

  def draw!
    update!(:completed => true)
  end

  private

  def generate_code
    self.update!(:code => "game#{self.id}")
  end
end

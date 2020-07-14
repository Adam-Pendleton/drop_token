class Board < ApplicationRecord
  WIN_COUNT = 4
  has_one :game
  serialize :board
  validates :height, :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :width, :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }

  before_create :initialize_board


  def add_token!(player, column)
    return false unless legal_move?(column)
    board[column].unshift(player.username) #push token onto front of column
    save!
  end

  def winning_move?(column)
    vertical_win?(column) ||
    horizontal_win?(column) ||
    diagonal_win?(column)
  end

  def vertical_win?(column)
    return false if board[column].count < 4
    player_color = board[column].first
    board[column].first(4).all? {|token| token == player_color}
  end

  def horizontal_win?(column)
    return false if width < 4
    row_height = board[column].count
    player_color = board[column].first
    row = board.map{|col| col[-row_height]} #get only the tokens of the row we're on
    chunks = row.chunk{|x| x} #group together consecutive tokens
    chunks.any?{|group_color, token_group| group_color == player_color && token_group.count >= 4}
  end

  def diagonal_win?(column)
    return false if height < 4 or width < 4

    player_color = board[column].first
    row = board[column].size

    asc_line=(-3..3).map do |i|
      board.dig(column+i, -(row+i))
    end
    asc_chunks=asc_line.chunk{|x| x} #group together consecutive tokens
    return true if asc_chunks.any?{|group_color, token_group| group_color == player_color && token_group.count >= 4}

    desc_line=(-3..3).map do |i|
      board.dig(column+i, -(row-i))
    end
    desc_chunks=desc_line.chunk{|x| x} #group together consecutive tokens
    desc_chunks.any?{|group_color, token_group| group_color == player_color && token_group.count >= 4}
  end

  def draw?
    board.all?{ |col| col.count >= height }
  end

  def legal_move?(column)
    column < width && column >= 0 && board[column].count < height
  end

  private

  def initialize_board
    self.board = []
    width.times do
      self.board << []
    end
  end
end

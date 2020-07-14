class GamesController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def index
    game_codes = Game.in_progress.map(&:code)
    render :json => { games: game_codes }
  end

  def show
    game = Game.find_by(:code => params[:game_code])
    if game.blank?
      render :json => { error: "Game not found" }, :status => 404
      return
    end
    return_hash = {
        players: game.players.map(&:username),
        state: game.completed ? "DONE" : "IN PROGRESS"
    }
    if game.completed?
      return_hash[:winner] = game.winner.username
    end
    render :json => return_hash
  end

  def create
    params.require(['columns', 'rows', 'players'])
    if params[:players].count < Game::MIN_PLAYER_COUNT
      render :json => { error: "Not enough players. Game requires at least #{Game::MIN_PLAYER_COUNT} players" }, :status => 400
      return
    end

    if params[:players].count > Game::MAX_PLAYER_COUNT
      render :json => { error: "Too many players. Game can have at most #{Game::MAX_PLAYER_COUNT} players" }, :status => 400
      return
    end

    players = params[:players].map do |username|
      Player.get_or_create_player(username)
    end
    rows = params[:rows] # TODO: validate rows and columns
    cols = params[:columns]
    game = Game.start_new(players, rows, cols)
    unless game&.persisted?
      render :json => { :error => 'failed to create game'}, :status => 500
      return
    end
    render :json => { :gameId => game.code }
  end
end
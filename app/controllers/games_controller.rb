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
      return_hash[:winner] = game.winner&.username
    end
    render :json => return_hash
  end

  def create
    begin
      params.require([:columns, :rows, :players])
      safe_params = params.permit(:columns, :rows, :players => [])
    rescue ActionController::ParameterMissing => e
      render :json => { error: "Missing required param: #{e.param}" }, :status => 400
      return
    end

    begin
      rows = Integer(safe_params[:rows])
      cols = Integer(safe_params[:columns])
    rescue ArgumentError
      render :json => { error: 'Malformed request - cols and rows must be positive integers' }, :status => 400
      return
    end

    if rows < 1 or cols < 1
      render :json => { error: 'Malformed request - cols and rows must be greater than 0' }, :status => 400
      return
    end

    usernames = safe_params[:players].uniq
    if usernames.count < Game::MIN_PLAYER_COUNT
      render :json => { error: "Not enough players. Game requires at least #{Game::MIN_PLAYER_COUNT} players" }, :status => 400
      return
    end

    if usernames.count > Game::MAX_PLAYER_COUNT
      render :json => { error: "Too many players. Game can have at most #{Game::MAX_PLAYER_COUNT} players" }, :status => 400
      return
    end

    players = usernames.map do |username|
      Player.get_or_create_player(username)
    end
    game = Game.start_new(players, rows, cols)
    unless game&.id.present?
      render :json => { :error => 'Server error - failed to create game'}, :status => 500
      return
    end

    render :json => { :gameId => game.code }
  end
end
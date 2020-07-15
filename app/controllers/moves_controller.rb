class MovesController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def index
    if params[:start].present?
      begin
        start = Integer(params[:start])
      rescue ArgumentError
        render :json => { error: 'Malformed request - the start parameter must be an integer' }, :status => 400
        return
      end
      if start < 0
        render :json => { error: 'Malformed request - The start parameter must be non-negative' }, :status => 400
        return
      end
    end

    if params[:until].present?
      begin
        til = Integer(params[:until])
      rescue ArgumentError
        render :json => { error: 'Malformed request - The until parameter must be an integer' }, :status => 400
        return
      end
      if til < 0
        render :json => { error: 'Malformed request - The until parameter must be non-negative' }, :status => 400
        return
      end

      if start.present? && til < start
        render :json => { error: 'The until parameter must not be lower than the start parameter' }, :status => 400
        return
      end
      count = start.present? ? til - start + 1 : til + 1
    end

    game = Game.find_by(:code => params[:game_code])
    if game.nil?
      render :json => { error: 'Game not found' }, :status => 404
      return
    end

    requested_moves = game.moves.order(:created_at).offset(start).limit(count)
    render :json => { 'moves': requested_moves.map(&:to_hash) }
  end

  def show
    game = Game.find_by(:code => params[:game_code])
    move = Move.find_by(:game => game, :move_number => params[:move_number])
    if game.nil? || move.nil?
      render :json => { error: "Game/move not found" }, :status => 404
      return
    end
    render :json => move.to_hash
  end

  def new
    safe_params = params.permit(:game_code, :username, :column)
    game = Game.find_by(:code => safe_params[:game_code])
    player = Player.find_by(:username => safe_params[:username])
    column = safe_params[:column]
    unless column.present?
      render :json => { error: "Malformed input. Column of move not provided." }, :status => 400
      return
    end

    unless column.is_a? Integer
      render :json => { error: "Malformed input. Column must be an integer." }, :status => 400
      return
    end

    if game.nil? || !game.active_player?(player)
      render :json => { error: 'Game not found or player is not a part of it' }, :status => 404
      return
    end

    if game.completed?
      render :json => { error: 'Game is already in DONE state.' }, :status => 410
      return
    end

    if game.next_player != player
      render :json => { error: "Player tried to post when it's not their turn." }, :status => 409
      return
    end

    if !game.legal_move?(column)
      render :json => { error: "Malformed input. Illegal move" }, :status => 400
      return
    end

    move = game.make_move!(player, column)

    if move.blank? || !move.persisted?
      render :json => { error: "An error occurred. Move was not recorded" }, :status => 500
      return
    end

    render :json => { "move": "#{game.code}/moves/#{move.move_number}" }
  end
end
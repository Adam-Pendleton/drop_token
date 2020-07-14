class MovesController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def index
    start = params[:start].to_i || 0
    if params[:until].present?
      count = params[:until].to_i - start
      if count < 0
        render :json => { error: 'The until parameter must not be lower than the start parameter' }, :status => 400
        return
      end
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
    #TODO: validate params
    game = Game.find_by(:code => params[:game_code])
    move = Move.find_by(:game => game, :move_number => params[:move_number])

    if game.nil? || move.nil?
      render :json => { error: "Game/move not found" }, :status => 404
      return
    end

    render :json => move.to_hash
  end

  def new
    #TODO: validate params
    game = Game.find_by(:code => params[:game_code])
    player = Player.find_by(:username => params[:username])

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

    if !game.legal_move?(params[:column])
      render :json => { error: "Malformed input. Illegal move" }, :status => 400
      return
    end

    move = game.make_move!(player, params[:column])

    if move.blank? || !move.persisted?
      render :json => { error: "An error occurred. Move was not recorded" }, :status => 500
      return
    end

    render :json => { "move": "#{game.code}/moves/#{move.move_number}" }
  end
end
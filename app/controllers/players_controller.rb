class PlayersController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def quit
    game = Game.find_by(:code => params[:game_code])
    player = Player.find_by(:username => params[:username])
    if game.nil? || player.nil? || !game.active_player?(player)
      render :json => { error: 'Game not found or player is not a part of it.' }, :code => 404
      return
    end
    
    if game.completed?
      render :json => { error: 'Game is already in DONE state.' }, :code => 410
      return
    end

    game.player_quit!(player)

    render :json => { message: "Quit request accepted" }, :code => 202
  end
end
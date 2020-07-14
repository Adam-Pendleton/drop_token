Rails.application.routes.draw do
  scope 'drop_token' do
    get '/', :controller => 'games', :action => 'index' #list all games
    post '/', :controller => 'games', :action => 'create'
    get ':game_code', :controller => 'games', :action => 'show' #get state of game
    get ':game_code/moves', :controller => 'moves', :action => 'index'
    post ':game_code/:username', :controller => 'moves', :action => 'new' #posts a move
    get ':game_code/moves/:move_number', :controller => 'moves', :action => 'show' #return info about the move
    delete ':game_code/:username', :controller => 'players', :action => 'quit'
  end
end

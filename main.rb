require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'your_secret'

answers = [
  ['Dr. Suess', ['T', 'H', 'E', ' ', 'C', 'A', 'T', ' ', 'I', 'N', ' ', 'T', 'H', 'E', ' ', 'H', 'A', 'T']],
  ['Famous Spy', ['J', 'A', 'M', 'E', 'S', ' ', 'B', 'O', 'N', 'D']]
]

get '/' do
  redirect '/new_game'
end

get '/new_game' do
  session[:guesses_made] = []
  answer = answers.sample
  session[:hint] = answer[0]
  session[:answer_array] = answer[1]
  session[:board_array] = answer[1].map { |space| space == " " ? " " : "_"}
  session[:guesses_left] = 10
  
  redirect '/game'
end

get '/game' do
  if session[:answer_array] == session[:board_array]
    redirect '/game_over'
  elsif session[:guesses_left] < 1
    redirect '/game_over'
  end
  
  erb :game
end

post '/player_guess' do
  guess = params[:guess].upcase
  if session[:guesses_made].include?(guess)
    @error = "You Already Made That Guess, Please Guess Again!"
    halt erb :game
  elsif !('A'..'Z').include?(guess)
    @error = "That is Not A Valid Guess, Please Guess Again!"
    halt erb :game
  elsif session[:answer_array].include?(guess)
    message = "That%20was%20a%20correct%20Guess!"
    
    session[:answer_array].each_with_index do |value, index|
      if value == guess
        session[:board_array][index] = guess
      end
    end
    
  else
    message = "That%20was%20an%20incorrect%20Guess!"
    session[:guesses_left] -= 1
  end
  
  session[:guesses_made] << guess
  redirect "/game?message=#{message}"
end

get '/game_over' do
  erb :game_over
end




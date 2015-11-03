require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'your_secret'

answers = [
  ['Dr. Suess', ['T', 'H', 'E', ' ', 'C', 'A', 'T', ' ', 'I', 'N', ' ', 'T', 'H', 'E', ' ', 'H', 'A', 'T']],
  ['Famous Spy', ['J', 'A', 'M', 'E', 'S', ' ', 'B', 'O', 'N', 'D']],
  ['Disney Character', ['M', 'I', 'C', 'K', 'E', 'Y', ' ', 'M', 'O', 'U', 'S', 'E']],
  ['State Capitol', ['C', 'O', 'L', 'U', 'M', 'B', 'U', 'S']],
  ['Apple', ['S', 'T', 'E', 'V', 'E', ' ', 'J', 'O', 'B', 'S']],
  ['Scarlet and Grey', ['O', 'H', 'I', 'O', ' ', 'S', 'T', 'A', 'T', 'E', ' ', 'B', 'U', 'C', 'K', 'E', 'Y', 'E', 'S']]
]

get '/' do
  redirect '/new_game'
end

get '/new_game' do
  session[:guesses_board] = []
  ('A'..'Z').each { |letter| session[:guesses_board] << letter }
  answer = answers.sample
  session[:hint] = answer[0]
  session[:answer_array] = answer[1]
  session[:board_array] = answer[1].map { |space| space == " " ? " " : "_"}
  session[:guesses_left] = 8
  
  redirect '/game'
end

get '/game' do
  redirect '/new_game' if !session[:answer_array]
  
  if session[:answer_array] == session[:board_array]
    redirect '/game_over'
  elsif session[:guesses_left] < 1
    redirect '/game_over'
  end
  
  erb :game
end

post "/guess" do
  if session[:answer_array].include?(params[:guess])
    message = "success=That%20was%20a%20correct%20Guess!"
    session[:answer_array].each_with_index do |value, index|
      if value == params[:guess]
        session[:board_array][index] = params[:guess]
      end
    end
  else
    message = "error=That%20was%20an%20incorrect%20Guess!"
    session[:guesses_left] -= 1
  end

  session[:guesses_board].delete(params[:guess])
  redirect "/game?#{message}"
end

get '/game_over' do
  redirect '/new_game' if !session[:answer_array]
  erb :game_over
end

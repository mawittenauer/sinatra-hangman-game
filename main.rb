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
  session[:guess] = nil
  
  redirect '/game'
end

get '/game' do
  redirect '/new_game' if !session[:answer_array]
  
  if session[:answer_array] == session[:board_array]
    redirect '/game_over'
  elsif session[:guesses_left] < 1
    redirect '/game_over'
  end
  
  if session[:guess]
    if session[:answer_array].include?(session[:guess])
      @success = "That Was A Correct Guess!"
      session[:answer_array].each_with_index do |value, index|
        if value == session[:guess]
          session[:board_array][index] = session[:guess]
        end
      end
    else
      @error = "That Was An Incorrect Guess!"
      session[:guesses_left] -= 1
    end
  end
  
  erb :game
end

post "/guess" do
  session[:guess] = params[:guess]
  redirect "/game"
end

get '/game_over' do
  redirect '/new_game' if !session[:answer_array]
  erb :game_over
end

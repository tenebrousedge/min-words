require 'sinatra'
require 'rubygems'
require 'json'

if development?
  require 'sinatra/reloader'
  also_reload('**/*.rb')
end

class MinWordsApp < Sinatra::Application
  D = MinWords::Dictionary.new
  get('/') do
    erb(:index)
  end

  post('/word/new') do
    content_type :json
    D.save_word(params.keys_to_symbol.fetch(:word))
    D.findAll.to_json
  end

  get('/word/:word') do
    @definitions = D.find(params[:word])
    erb(:word)
  end

  post('/definition/new') do
    content_type :json
    word_id = params.keys_to_symbol[:word][:id]
    D.find(params.keys_to_symbol[:word]).to_json
  end
  run! if app_file == $0
end
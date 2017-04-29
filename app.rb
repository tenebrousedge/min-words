require 'sinatra'
require 'rubygems'
require 'json'
require_relative './lib/min_words'
require 'pry'

if development?
  require 'sinatra/reloader'
  also_reload('**/*.rb')
end

class MinWordsApp < Sinatra::Application
  configure do
    D ||= MinWords::Dictionary.new
  end

  get('/') do
    @words = D.findAll
    erb(:index)
  end

  post('/word/new') do
    word = params.keys_to_symbol.fetch(:word)
    D.save_word(word)
    @words = D.findAll
    erb(:index)
  end

  get('/word/:word') do
    @words = D.find(params[:word])
    erb(:word)
  end

  post('/definition/new') do
    params = params.keys_to_symbol
    word_id = params[:word_id].to_i
    definition_text = params[:definition_text]
    D.save_definition(word_id, definition_text)
    @words = D.find(params[:word_text])
    erb(:word)
  end

  run! if app_file == $0
end

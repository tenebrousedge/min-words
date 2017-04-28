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
  D ||= MinWords::Dictionary.new
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
    word_id = params.keys_to_symbol[:word_id]
    definition_text = params.keys_to_symbol[:definition_text]
    binding.pry
    D.save_definition(word_id, definition_text)
    binding.pry
    @words = D.find(params.keys_to_symbol[:word_text])
    erb(:word)
  end

  run! if app_file == $0
end
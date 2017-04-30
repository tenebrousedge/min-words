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
  set :raise_errors, false
  set :show_exceptions, false
  configure do
    D ||= MinWords::Dictionary.new
  end

  get('/') do
    @words = D.findAll
    erb(:index)
  end

  post('/word/new') do
    word = params().keys_to_symbol.fetch(:word)
    begin
      D.save_word(word)
    rescue Sequel::UniqueConstraintViolation
      @errormessage = 'Sorry, that word already exists.'
    end
    @words = D.findAll
    erb(:index)
  end

  post('/word/new.json') do
    content_type :json
    word = params().keys_to_symbol.fetch(:word)
    message = {status: 'Success'}
    begin
      id = D.save_word(word)
    rescue Sequel::UniqueConstraintViolation
      message[:status] = 'Error'
      message[:errormessage] = 'Sorry, that word already exists.'
    end
    message[:new_word] = D.findBy id: id
    message.to_json
  end

  get('/word/:word') do
    @words = D.find(params[:word])
    erb(:word)
  end

  post('/definition/new') do
    pars = params().keys_to_symbol
    word_id = params[:word_id].to_i
    definition_text = pars[:definition_text]
    D.save_definition(word_id, definition_text)
    @words = D.find(pars[:word_text])
    erb(:word)
  end

  post('/definition/new.json') do
    content_type :json
    pars = params().keys_to_symbol
    word_id = params[:word_id].to_i
    definition_text = pars[:definition_text]
    D.save_definition(word_id, definition_text)
    {status: 'Success'}.merge(D.find(pars[:word_text])).to_json
  end

  run! if app_file == $0
end

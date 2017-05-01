require_relative './min_words/version'
require 'sequel'

# Namespace module for MinWords
#
# @author Kai Leahy
module MinWords
  # In-memory database initialization
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://database.db')

  # Sequel class referencing the words table
  class Word < Sequel::Model
    one_to_many :defines
  end

  # Sequel class referencing the definitions table
  class Define < Sequel::Model
    many_to_one :word
  end

  # Provides methods for storing and retrieving words and definitions
  class Dictionary
    # initialize the database upon instantiation
    def initialize
      create_tables
    end

    # save a word and definition to the database
    #
    # @param [Hash<String>] word
    def save_word(word)
      id = MinWords::DB[:words].insert word_text: word[:word_text]
      save_definition(id, word[:definition_text])
    end

    # save a definition to the database
    #
    # @param [String|Integer] word_id The id of the definition to be associated
    # @param [String] definition The new definition to be saved
    def save_definition(word_id, definition)
      MinWords::DB[:defines].insert definition_text: definition, word_id: word_id
    end

    # returns a specific word's definitions
    #
    # @param [String] word The word to find, as a string
    def find(word)
      w = MinWords::DB[:words].where(:word_text => word).first
      w.merge(definitions: definitions(w))
      findBy :word_text, word
    end

    # Finds a record by some key
    #
    # This could easily have been written just as a 'find by i'
    # @param [Hash|Symbol] key Either a hash containing a KVP or the field to search for, as a symbol.
    # @param [Object] value the value to be searched for
    def findBy(key, value = nil)
      args = key.respond_to?('keys') ? key :{key => value}
      words = MinWords::DB[:words].where(args).all
      words.map { |e| e.merge(definitions: definitions(e)) }[0]
    end

    # Returns all definitions for a given word.
    #
    # @param [String] word The word to find definitions for
    def definitions(word)
      MinWords::DB[:defines].where(word_id: word[:id]).all
    end
    # returns all words and their ids
    def findAll
      # returns the definitions as an array of definition hashes inside the hash for the individual words
      MinWords::DB[:words].all.map {|e| e.merge({ definitions: definitions(e)}) }
    end

    # Updates a word's definition
    #
    # @param [String|Integer] id The id of the word to update
    # @param [String] new_def The new definition to save
    def update_definition(id, new_def)
      MinWords::DB[:defines]
      .where(id: id)
      .update(:definition_text => new_def)
    end

    # Creates the database tables
    #
    # This is not the right way to do this.
    # The appropriate thing would be to create a migration file
    # I didn't feel like learning that quite yet. I'm sure we'll get around to that with Rails.
    def create_tables
      unless MinWords::DB.table_exists?(:words)
        MinWords::DB.create_table :words do
          primary_key :id
          varchar :word_text, unique: true
        end
      end
      unless MinWords::DB.table_exists?(:defines)
        MinWords::DB.create_table :defines do
          primary_key :id
          foreign_key :word_id, :words
          varchar :definition_text
        end
      end
    end

    # drops the defines and words tables and recreates them
    def clear_tables
      # the order of operations here is important because of the foreign key constraint
      MinWords::DB.drop_table :defines, :words
      create_tables
    end
  end
end

# Adds a method to the Hash class
#
# We're extending the global object because, hey, if Rails can do it...
class Hash
  # recursively turns string hash keys to symbols
  #
  # this will blow up if the key does not respond to to_sym. So basically just strings.
  # yardoc says this method needs to be documented. This is super meaningful documentation.
  # It's gorgeous really. _why would approve.
  def keys_to_symbol
    # changing this to use responds_to? because it's more Ruby-ish
    # in Ruby and Smalltalk-influenced object-oriented languages method calls simply send a message to an object
    # the idea of 'duck typing' is that we don't care if it *is* a duck, we just care if it quacks like one
    Hash[self.map { |k,v| [k.to_sym, v.respond_to?(:keys_to_symbol) ? v.keys_to_symbol : v] }]
  end
end

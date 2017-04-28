require 'min_words/version'
require 'sequel'
require 'sqlite3'

# Namespace module for MinWords
#
# @author Kai Leahy
module MinWords
  # In-memory database initialization
  DB = Sequel.sqlite

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
    # @param [Hash<String>] definition
    def save_word(word, definition)
      id = MinWords::DB[:words].insert word
      MinWords::DB[:defines].insert definition.merge(word_id: id)
    end

    # returns a specific word's definitions
    #
    # @param [String] word The word to find, as a string
    def find(word)
      MinWords::DB[:words]
      .where(:word_text => word)
      .left_join(:defines, :word_id => :id)
      .first
    end

    # returns all words and their ids
    def findAll
      MinWords::DB[:words]
      .left_join(:defines, :word_id => :id)
      .all
    end

    # Updates a word's definition
    #
    # #param []
    def update_definition(id, new_def)
      MinWords::DB[:defines]
      .where(id: id)
      .update(:definition_text => new_def)
    end

    def create_tables
      unless MinWords::DB.table_exists?(:words)
        MinWords::DB.create_table :words do
          primary_key :id
          varchar :word_text
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

    def clear_tables
      MinWords::DB.drop_table :defines, :words
      create_tables
    end
  end
end

class Hash
  def keys_to_symbol
    Hash[self.map { |k,v| [k.to_sym, v.is_a?(Hash) ? v.keys_to_symbol : v] }]
  end
end

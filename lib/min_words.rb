require_relative './min_words/version'
require 'min_words/dictionary'
require 'sequel'

# Namespace module for MinWords.
#
# @author Kai Leahy
module MinWords
  # In-memory database initialization
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://database.db')

  # Sequel class referencing the words table.
  #
  # @!parse extend Sequel::Model
  class Word < Sequel::Model
    one_to_many :defines
  end

  # Sequel class referencing the definitions table.
  #
  # @!parse extend Sequel::Model
  class Define < Sequel::Model
    many_to_one :word
  end
end

# Adds a method to the Hash class.
#
# @note We're extending the global object because, hey, if Rails can do it...
class Hash
  # Recursively turns string hash keys to symbols.
  #
  # This will blow up if the key does not respond to to_sym. So basically just strings.
  # yardoc says this method needs to be documented. This is super meaningful documentation.
  # It's gorgeous really. _why would approve.
  # @return A new hash with symbols instead of string keys.
  def keys_to_symbol
    # changing this to use responds_to? because it's more Ruby-ish
    # in Ruby and Smalltalk-influenced object-oriented languages method calls simply send a message to an object
    # the idea of 'duck typing' is that we don't care if it *is* a duck, we just care if it quacks like one
    Hash[self.map { |k,v| [k.to_sym, v.respond_to?(:keys_to_symbol) ? v.keys_to_symbol : v] }]
  end
end

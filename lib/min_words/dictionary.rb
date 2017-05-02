module MinWords
  # Provides methods for storing and retrieving words and definitions.
  class Dictionary
    # Initializes the database tables upon instantiation.
    def initialize
      create_tables
    end

    # Save a word and definition to the database.
    #
    # @param word [Hash<String>] A hash containing the word to be saved. Keys must be :word_text and :definition_text.
    # @raise Sequel::UniqueConstraintViolation if the word already exists.
    # @return [Integer] The id of the saved word.
    def save_word(word)
      id = MinWords::DB[:words].insert word_text: word[:word_text]
      save_definition(id, word[:definition_text])
      id
    end

    # Save a definition to the database.
    #
    # @param word_id [String|Integer] The id of the definition to be associated.
    # @param definition [String] The new definition to be saved.
    # @return [Integer] The id of the saved definition.
    def save_definition(word_id, definition)
      MinWords::DB[:defines].insert definition_text: definition, word_id: word_id
    end

    # Find a specific word and its definitions.
    #
    # @param word [String] The word to find, as a string.
    # @return [Hash] The word found.
    def find(word)
      findBy :word_text, word
    end

    # Finds a record by some key.
    #
    # @note This could easily have been written just as a 'find by id' method, but I like having the generic method.
    # @overload findBy(key, value)
    #   Find a record by some key and value.
    #   @param key [Symbol] Either a hash containing a KVP or the field to search for, as a symbol.
    #   @param value [Object] The value to be searched for.
    # @overload findBy(hash)
    #   Find a record using a key => value pair.
    #   @param hash [Hash] A hash containing one or more find conditions.
    # @return [Hash, nil] The word found, or nil for nonexistent records.
    def findBy(key, value = nil)
      args = key.respond_to?('keys') ? key :{key => value}
      words = MinWords::DB[:words].where(args).all
      words.map { |e| e.merge(definitions: definitions(e)) }[0]
    end

    # Returns all definitions for a given word.
    #
    # @param word [String] The word to find definitions for.
    # @return [Array<Hash>] An array of definitions.
    def definitions(word)
      MinWords::DB[:defines].where(word_id: word[:id]).all
    end

    # Returns all words and their ids.
    # @return [Array<Hash>] An array of all stored words.
    def findAll
      # returns the definitions as an array of definition hashes inside the hash for the individual words
      MinWords::DB[:words].all.map {|e| e.merge({ definitions: definitions(e)}) }
    end

    # Updates a word's definition
    #
    # @param id [String|Integer] The id of the word to update
    # @param new_def [String] The new definition to save
    # @return [nil]
    def update_definition(id, new_def)
      MinWords::DB[:defines]
      .where(id: id)
      .update(:definition_text => new_def)
    end

    # Creates the database tables.
    #
    # This is not the right way to do this.
    # The appropriate thing would be to create a migration file
    # I didn't feel like learning that quite yet. I'm sure we'll get around to that with Rails.
    # @return [nil]
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

    # Drops the defines and words tables and recreates them.
    # @return [nil]
    def clear_tables
      # the order of operations here is important because of the foreign key constraint
      MinWords::DB.drop_table :defines, :words
      create_tables
    end
  end
end

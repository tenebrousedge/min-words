require "spec_helper"
require 'pry'

RSpec.describe MinWords do
  it "has a version number" do
    expect(MinWords::VERSION).not_to be nil
  end

  describe MinWords::Dictionary do
    it "initializes database tables" do
      dict = MinWords::Dictionary.new
      expect(MinWords::DB).to be_a Sequel::Database
      expect(MinWords::DB[:words].columns).to match_array([:id, :word_text])
      expect(MinWords::DB[:defines].columns).to match_array([:id, :word_id, :definition_text])
    end

    describe 'MinWords::Dictionary#clear_tables' do
      it "deletes database tables" do
        @dict = MinWords::Dictionary.new
        @dict.clear_tables
        expect(MinWords::DB[:words].empty?).to eq(true)
        expect(MinWords::DB[:defines].empty?).to eq(true)
      end
    end

    describe 'MinWords::Dictionary#save_word' do
      before() do
        @dict = MinWords::Dictionary.new
        @dict.clear_tables
      end
      it "saves words to the database" do
        word = {word_text: 'meow', definition_text: 'a shocking word, never to be used.'}
        expect(@dict.save_word(word)).to(eq(1))
      end
    end

    describe 'MinWords::Dictionary#find' do
      before() do
        @dict = MinWords::Dictionary.new
        word = {word_text: 'meow', definition_text: 'a shocking word, never to be used.'}
        @dict.clear_tables
        @dict.save_word(word)
      end

      it "finds words in the dictionary" do
        e = {:id=>1, :word_text=>"meow", :definitions=>[{:id=>1, :word_id=>1, :definition_text=>"a shocking word, never to be used."}]}
        expect(@dict.find('meow')).to(eq(e))
      end

      it "returns nil for nonexistent words" do
        expect(@dict.find('bark')).to be_nil
      end
    end

    describe 'MinWords::Dictionary#findBy' do
      before() do
        @dict = MinWords::Dictionary.new
        word = {word_text: 'meow', definition_text: 'a shocking word, never to be used.'}
        @dict.clear_tables
        @dict.save_word(word)
      end

      it "finds words in the dictionary" do
        e = {:id=>1, :word_text=>"meow", :definitions=>[{:id=>1, :word_id=>1, :definition_text=>"a shocking word, never to be used."}]}
        expect(@dict.findBy(:word_text, 'meow')).to(eq(e))
        expect(@dict.findBy(:id, 1)).to(eq(e))
      end

      it "returns nil for nonexistent words" do
        expect(@dict.findBy(:word_text, 'bark')).to be_nil
      end
    end

    describe 'MinWords::Dictionary#findAll' do
        before() do
        word = {:id=>1, :word_text=>"meow", :definition_text=>"a shocking word, never to be used."}
        @dict = MinWords::Dictionary.new
        @dict.clear_tables
        @dict.save_word(word)
      end

      it "finds all words and definitions" do
        e = [{:id=>1, :word_text=>"meow", :definitions=>[{:id=>1, :word_id=>1, :definition_text=>"a shocking word, never to be used."}]}]
        expect(@dict.findAll).to(eq(e))
      end
    end
  end
end

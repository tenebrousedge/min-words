require_relative 'spec_helper'

describe 'adding words', :type => :feature do
  it 'adds a word to the page using the form' do
    word = 'pokemon exception handling'
    definition = 'when you gotta catch them all'
    visit '/'
    within('#new_word') do
      fill_in 'word[word_text]', with: word
      fill_in 'word[definition_text]', with: definition
    end
    click_button 'Store Word'
    expect(page).to have_content word
    expect(page).to have_content definition
  end
end

describe 'adding definitions', :type => :feature do
  it 'shows all definitions of a word' do
    word = 'heisenbug'
    definition = 'A computer bug that disappears or alters its characteristics when an attempt is made to study it.'
    visit '/'
    within('#new_word') do
      fill_in 'word[word_text]', with: word
      fill_in 'word[definition_text]', with: definition
    end
    click_button 'Store Word'
    click_link word
    expect(page).to have_current_path('/word/' + word)
    expect(page).to have_content definition
  end

  it 'lets people add new definitions to a word' do
    word = 'bicrement'
    definition = 'adding two to a variable'
    other_definition = 'some other definition'
    visit '/'
    within('#new_word') do
      fill_in 'word[word_text]', with: word
      fill_in 'word[definition_text]', with: definition
    end
    click_button 'Store Word'
    click_link word
    fill_in 'definition_text', with: other_definition
    click_button 'Add New Definition'
    expect(page).to have_content other_definition
  end
end

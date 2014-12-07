require 'spec_helper'

feature 'Users' do
  background do
    rom.relations.users.insert(name: 'Jane')
    rom.relations.users.insert(name: 'Joe')
  end

  scenario 'I see user list on index page' do
    visit '/users'

    expect(page).to have_content('Jane')
    expect(page).to have_content('Joe')
  end

  scenario 'I can search users' do
    visit '/users/search?name=Jane'

    expect(page).to have_content('Jane')
    expect(page).to_not have_content('Joe')
  end
end

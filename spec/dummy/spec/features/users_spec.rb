require 'spec_helper'

feature 'Users' do
  background do
    Rails.application.config.rom.env.relations.users.insert(name: 'Piotr')
  end

  scenario 'I see user list on index page' do
    visit '/users'

    expect(page).to have_content('Piotr')
  end
end

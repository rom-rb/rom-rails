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

  scenario 'I save a new user' do
    visit '/users/new'

    click_on 'Create User'
    expect(page).to have_content("can't be blank")

    find('#user_email').set('jade@doe.org')
    find('#user_name').set('Jade')
    click_on 'Create User'

    expect(page).to have_content('Jade')
    expect(page).to have_content('Jane')
    expect(page).to have_content('Joe')
  end

  scenario 'I edit an existing user' do
    jane = rom.relations.users.by_name('Jane').first
    visit "/users/#{jane[:id]}/edit"

    click_on 'Update User'
    expect(page).to have_content("can't be blank")

    find('#user_email').set('jane.doe@example.org')
    find('#user_name').set('Jane Doe')
    click_on 'Update User'

    expect(page).to have_content('Jane Doe')
    expect(page).to have_content('Joe')
  end

  scenario 'I can search users' do
    visit '/users/search?name=Jane'

    expect(page).to have_content('Jane')
    expect(page).to_not have_content('Joe')
  end
end

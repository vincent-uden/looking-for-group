require_relative 'spec_helper'

feature 'Entering the web page' do
  scenario 'succesfully creates a new user' do
    visit '/'
    click_button 'Register Account'
    expect(page).to have_content 'Register Account'
    within '#registerForm' do
      fill_in 'username',         with: Helper.TEST_USERNAME
      fill_in 'email',            with: Helper.TEST_EMAIL
      fill_in 'password',         with: Helper.TEST_PASSWORD
      fill_in 'confirm-password', with: Helper.TEST_PASSWORD
      fill_in 'rsn',              with: Helper.TEST_RSN
    end
    click_button 'Register'
  end

  scenario 'Entering username, password and logging in' do
    visit '/'
    expect(page).to have_content 'Welcome'
    within '#loginForm' do
      fill_in 'username', with: Helper.TEST_USERNAME
      fill_in 'password', with: Helper.TEST_PASSWORD
    end
    click_button 'Log in'
    expect(page).to have_content "Welcome #{Helper.TEST_USERNAME}"
    within 'nav' do
      click_button 'Log out'
    end
  end
end



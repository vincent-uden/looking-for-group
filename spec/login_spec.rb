require_relative 'spec_helper'

TEST_USERNAME = 'rspecUser'
TEST_EMAIL = 'rspecEmail'
TEST_PASSWORD = 'rspecPassword'
TEST_RSN = 'Skroomoomlie'

describe 'creating a new user', type: :feature do
  it 'succesfully creates a new user' do
    visit '/'
    click_button 'Register Account'
    expect(page).to have_content 'Register Account'
    within '#registerForm' do
      fill_in 'username',         with: TEST_USERNAME
      fill_in 'email',            with: TEST_EMAIL
      fill_in 'password',         with: TEST_PASSWORD
      fill_in 'confirm-password', with: TEST_PASSWORD
      fill_in 'rsn',              with: TEST_RSN
    end
    click_button 'Register'
  end
end

describe 'the signin process', type: :feature do
  it 'signs me in' do
    visit '/'
    expect(page).to have_content 'Welcome'
    within '#loginForm' do
      fill_in 'username', with: TEST_USERNAME
      fill_in 'password', with: TEST_PASSWORD
    end
    click_button 'Log in'
    expect(page).to have_content "Welcome #{TEST_USERNAME}"
  end
end



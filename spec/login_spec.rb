require_relative 'spec_helper'

describe 'creating a new user', type: :feature do
  it 'succesfully creates a new user' do
    visit '/'
    click_button 'Register Account'
    expect(page).to have_content 'Register Account'
    within '#registerForm' do
      fill_in 'username',         with: 'rspecUser'
      fill_in 'email',            with: 'rspecEmail'
      fill_in 'password',         with: 'rspecPassword'
      fill_in 'confirm-password', with: 'rspecPassword'
      fill_in 'rsn',              with: 'Skroomoomlie'
    end
    click_button 'Register'
  end
end

describe 'the signin process', type: :feature do
  it 'signs me in' do
    visit '/'
    expect(page).to have_content 'Welcome'
    within '#loginForm' do
      fill_in 'username', with: 'xorvralin2'
      fill_in 'password', with: 'testpass123'
    end
    click_button 'Log in'
    expect(page).to have_content 'Welcome xorvralin2'
  end
end



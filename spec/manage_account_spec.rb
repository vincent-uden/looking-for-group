require_relative 'spec_helper'

feature 'Account' do
  before :each do
    visit '/'
    within '#loginForm' do
      fill_in 'username', with: Helper.TEST_USERNAME
      fill_in 'password', with: Helper.TEST_PASSWORD
    end
    click_button 'Log in'
  end

  scenario 'looking at your friends' do
    visit '/account/show'
    expect(page).to have_content 'Friends'
  end
end

require_relative 'spec_helper'

describe "the signin process", type: :feature do
  it "signs me in" do
    visit '/'
    p page.body
    expect(page).to have_content 'Welcome'
  end
end

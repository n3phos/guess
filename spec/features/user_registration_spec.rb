require 'rails_helper'

feature "User registration" do
  scenario "User creates a new account"  do
    visit "/"
    fill_in 'user_nick', :with => 'godfather'
    click_on 'Start'
    expect(page).to have_text("godfather")
  end

end

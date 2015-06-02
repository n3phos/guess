
require 'rails_helper'

feature "Chat" do

  scenario "User writes a message in chat", :js => true do

    visit '/'
    fill_in 'user_nick', with: 'bart'
    click_button "Start"

    fill_in "usermsg", with: "test nachricht"
    #find("#usermsg").native.send_keys(:return)

    page.execute_script("$('#usermsg').trigger(jQuery.Event('keypress', { which: 13 }));")

    expect(page).to have_content("test nachricht")



  end

end

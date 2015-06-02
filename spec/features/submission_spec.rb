
require 'rails_helper'

feature "Submission" do

  before do
    create :category, name: "Movie"
    create :category, name: "Game"
    create :category, name: "Series"
  end

  scenario "User submits a new theme" do

    # create a user first
    visit '/'
    fill_in 'user_nick', :with => 'hansolo'
    click_on 'Start'

    visit '/themes'
    click_link 'New Submission'

    fill_in 'theme_video_id', with: 'https://www.youtube.com/watch?v=sa9CvDPXYNI'
    fill_in 'theme_media_name', with: 'Game of Thrones'
    fill_in 'theme_theme_name', with: 'Rains of Castamere'
    fill_in 'theme_theme_interpret', with: 'Ramin Djawai'
    fill_in 'theme_start_seconds', with: 10
    fill_in 'theme_end_seconds', with: 0

    fill_in 'theme_questions_attributes_0_ques', with: 'Which main character got killed in S1?'
    fill_in 'theme_questions_attributes_0_answer', with: 'Eddard Stark'

    select 'Series', :from => 'theme_category_id'
    attach_file('theme_media_image', 'spec/fixtures/images/Game-Of-Thrones-Season-1.jpg')

    click_on "Submit Theme"

    within("div#subm") do
      expect(page).to have_content("Rains of Castamere")
      expect(page).to have_content("hansolo")
    end

  end
end

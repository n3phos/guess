require 'rails_helper'
require 'paperclip/matchers'

RSpec.configure do |config|
  config.include Paperclip::Shoulda::Matchers
end

describe Theme do

  describe "Associations" do
    it { should have_many(:gamerecords) }
    it { should have_many(:games).through(:gamerecords) }
    it { should have_many(:theme_questions) }
    it { should have_many(:questions).through(:theme_questions) }
    it { should have_one(:submission).dependent(:destroy) }
    it { should belong_to(:category) }
    it { should accept_nested_attributes_for :questions }
  end

  it "has a valid factory" do
    expect(create(:theme)).to be_valid
  end

  it "has a game theme factory" do
    expect(create(:game_theme)).to be_valid
  end

  it "has a series theme factory" do
    expect(create(:series_theme)).to be_valid
  end

  it "validates that video_id is valid youtube link" do
    theme = Theme.new(video_id: "https://google.com")
    theme.valid?
    expect(theme.errors.full_messages).to include("Video has to be a valid youtube link")
  end

  it "saves only the video id from the youtube link" do
    theme = Theme.new(video_id: "https://www.youtube.com/watch?v=1aV9X2d-f5g")
    theme.save
    expect(theme.video_id).to eq("1aV9X2d-f5g")
  end

  it "validates the attachment content type" do
    theme = Theme.new(video_id: "https://www.youtube.com/watch?v=1aV9X2d-f5g")
    expect(theme).to validate_attachment_content_type(:media_image).
        allowing('image/png').
        rejecting('text/plain')
  end

  describe "#generate_record" do

    before do
      @theme = create :theme
      1.upto(10) do |i|
        @theme.questions.create(ques: "question_#{i}", answer: "answ")
      end
      @theme.questions.update_all(reviewed: true)
    end

    it "returns a record with random question / answer entries" do
      rec = @theme.generate_record
      expect(rec['video_id']).to eq(@theme.video_id)
      expect(rec['entries']).to be_a(Array)

      first_question = rec['entries'][0]

      expect(first_question).to include("q", "a")
      expect(first_question["q"]).to eq(@theme.category.name)
      expect(first_question["a"]).to eq(@theme.media_name)

      questions = rec['entries'].collect { |e| e["q"] }
      questions2 = @theme.generate_record['entries'].collect { |e| e["q"]  }

      expect(questions).to_not eq(questions2)
    end


  end


end

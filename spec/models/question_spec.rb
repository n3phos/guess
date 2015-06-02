
require 'rails_helper'

describe Question do

  describe "Associations" do
    it { should have_many(:theme_questions) }
    it { should have_many(:themes).through(:theme_questions) }
  end

  it { should validate_presence_of(:ques) }
  it { should validate_presence_of(:answer) }

  it "is not reviewed per default" do
    q = Question.create(ques: "fuu", answer: "bar", reviewed: true)
    expect(q.reviewed).to be false
  end


end

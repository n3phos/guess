class Question < ActiveRecord::Base

  has_many :theme_questions
  has_many :themes, through: :theme_questions

  validates :ques, :answer, :presence => true

end

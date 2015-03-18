class Question < ActiveRecord::Base

  has_many :theme_questions
  has_many :themes, through: :theme_questions

  validates :ques, :answer, :presence => true,
                            :format => { :with => /\A[A-Za-z0-9\-',_.? ]+\z/ }

  before_create :set_not_reviewed

  def set_not_reviewed
    self.reviewed = false
    return true
  end

end

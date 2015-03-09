class ThemeQuestion < ActiveRecord::Base

  belongs_to :theme
  belongs_to :question

end

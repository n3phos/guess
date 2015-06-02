require 'rails_helper'

describe ThemeQuestion do

  it { should belong_to(:theme) }
  it { should belong_to(:question) }

end

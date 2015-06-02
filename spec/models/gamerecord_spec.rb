require 'rails_helper'

describe Gamerecord do

  it { should belong_to(:theme) }
  it { should belong_to(:game) }
  it { should have_one(:history) }

end

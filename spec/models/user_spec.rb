require 'rails_helper'

describe User do

  it { should allow_value("MrFancyPants").for(:nick) }
  it { should allow_value("moon123").for(:nick) }
  it { should_not allow_value("sh!t@").for(:nick) }

  it { should validate_length_of(:nick).is_at_most(12) }
  it { should validate_uniqueness_of(:nick) }

  it "should provide a unique default value for irc nick" do
    u1 = User.create(nick: "foo")
    u2 = User.create(nick: "bar")

    expect(u1.irc_nick).to_not be_nil
    expect(u1.irc_nick).to_not eq(u2.irc_nick)
  end


end

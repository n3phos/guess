FactoryGirl.define do
  factory :user do
    initialize_with { new(nick: "michael", irc_nick: "") }
  end

end

require 'rails_helper'

describe RoomsController do
  include ApplicationHelper

  describe "GET #join" do

    context "without current user" do

      it "should redirect to home" do

        get :join, name: 'lobby'
        expect(response).to_not render_template(:join)
        expect(response).to redirect_to(:home)
        expect(flash[:error]).to eq("Can't join room, please choose a nickname")
      end

    end

    # turn on irc handler before
    context "with current user" do
      let(:user) { create :user }
      before { sign_in user }

      it "assigns @room" do
        get :join, name: 'lobby'
        expect(assigns(:room)).not_to be_nil
      end

      it "adds current user to room userlist" do
        get :join, name: 'lobby'
        expect(assigns(:room).users).to include(user.irc_nick.to_sym)
      end

      it "should render join" do
        get :join, name: 'lobby'
        expect(response).to render_template(:join)
      end

    end
  end

  describe "GET #leave" do
    let(:user) { create :user }
    before { sign_in(user) }

    it "assigns @room" do
      xhr :get, :leave, name: 'lobby'
      expect(assigns(:room)).not_to be_nil
    end

    it "removes current user from room userlist" do
      get :join, name: 'lobby'
      xhr :get, :leave, name: 'lobby'

      expect(assigns(:room).users).not_to include(user.irc_nick.to_sym)
    end

    it "assigns @redir_to_rooms if the origin is from chat controls" do
      xhr :get, :leave, name: 'lobby', origin: "chatcontrols"
      expect(assigns(:redir_to_rooms)).to eq("#{root_url}rooms")
    end
  end

  describe "GET #index" do

    it "renders the :index view" do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe "GET #info" do
    let(:user) { create :user }
    before { sign_in(user) }

    it "responds with json" do
      xhr :get, :info, name: 'lobby'
      json = JSON.parse(response.body)
      expect(json['name']).to_not be_nil
      expect(json['room_operator']).to_not be_nil
      expect(json['users']).to_not be_nil
      expect(json['channel']).to_not be_nil
      expect(json['current_user']['name']).to_not be_nil
      expect(json['current_user']['irc_nick']).to_not be_nil
    end
  end
end

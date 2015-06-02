require 'rails_helper'

describe UsersController do

  include ApplicationHelper

  describe "GET #new" do
    it "renders new" do
      get :new
      expect(response).to render_template("new")
    end
  end

  describe "POST #create" do

    it "registers new user" do
      post :create, user: { :nick => "newuser" }

      user = assigns(:user)
      expect(user).to_not be_nil
      expect(session[:user_id]).to be(user.id)
      expect(response).to redirect_to("/rooms/lobby")
    end

    it "renders new on error" do
      post :create, user: { :nick => "thisusernameistoolong" }
      expect(response).to render_template("new")
    end
  end

  describe "PATCH #update" do
    it "changes the nickname" do
      user = create :user
      sign_in user
      put :update, id: user.id, user: { :nick => "mcfancy" }
      expect(current_user.nick).to eq("mcfancy")
    end

  end
end

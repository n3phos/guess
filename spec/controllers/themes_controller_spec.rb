require 'rails_helper'

describe ThemesController do

  include ApplicationHelper

  describe "GET #new" do

    context "with unregistered user" do
      it "should redirect to home" do
        get :new
        expect(response).to redirect_to(:home)
        expect(flash[:error]).to eq("Please choose a nickname to make a new submission")
      end
    end

    context "with registered user" do
      let(:user) { create :user }
      before { sign_in user }

      it "should render new" do
        get :new
        expect(response).to render_template("new")
      end

      it "builds three theme questions" do
        get :new
        expect(assigns(:theme).questions.size).to eq(3)
      end

      it "assigns @submissions" do
        get :new
        expect(assigns(:submissions)).to_not be_nil
      end
    end

  end

  describe "GET #show" do
    before { @t = create :theme }
    it "renders show" do

      get :show, id: @t.id
      expect(response).to render_template("show")
    end
  end

  describe "POST #create" do

    include ActionDispatch::TestProcess

    before :each do
      sign_in(create :user)
      @file = fixture_file_upload('images/Game-Of-Thrones-Season-1.jpg', 'image/jpeg')
    end


    it "creates a new theme" do
      post :create, :theme => {
                                :video_id => 'https://www.youtube.com/watch?v=sa9CvDPXYNI',
                                :media_name => 'Game of Thrones',
                                :media_image => @file,
                                :category_id => '1',
                                :theme_name => 'Rains of Castamere',
                                :theme_interpret  =>'',
                                :start_seconds =>"0",
                                :end_seconds => "0",
                                :questions_attributes => {
                                  :ques => "xyz?",
                                  :answer => "efg" }
                              }

      expect(assigns(:theme)).to be_valid
      expect(response).to redirect_to ("/themes/new")
    end

    it "filters out blank questions and answers" do

      post :create, :theme => {
                                :video_id => 'https://www.youtube.com/watch?v=sa9CvDPXYNI',
                                :media_name => 'Game of Thrones',
                                :media_image => @file,
                                :category_id => '1',
                                :theme_name => 'Rains of Castamere',
                                :theme_interpret  =>'',
                                :start_seconds =>"0",
                                :end_seconds => "0",
                                :questions_attributes => {
                                  "0" => { 'ques' => "xyz?",
                                           'answer' => "efg"},
                                  "1" => { 'ques' => "invalid question",
                                           'answer' => "" },
                                  "2" => { 'ques' => "xug?",
                                           'answer' => "sdf" }
                                }
                              }
      qs = assigns(:theme).questions.collect { |q| q.ques }

      expect(qs).to include("xyz?")
      expect(qs).to include("xug?")
      expect(qs).to_not include("invalid question")
      expect(qs.length).to eq(2)
    end

    describe "GET #index" do
      it "renders index view" do
        get :index
        expect(assigns(:themes)).to_not be_nil
        expect(response).to render_template("index")
      end
    end

    describe "GET #edit" do
      before { @t = create :theme }
      it "renders edit view" do
        get :edit, id: @t.id
        expect(response).to render_template("edit")
      end
    end

    describe "PATCH #update" do
      before { @t = create :theme }
      it "should update the questions" do
        patch :update, id: @t.id, :theme => { :questions_attributes =>
                                   {
                                     "0" => { 'ques' => "new question?",
                                              'answer' => "efg"}
                                   }
                                 }

        qs = assigns(:theme).questions.collect { |q| q.ques }

        expect(qs).to include("new question?")
        expect(response).to redirect_to(:action => 'edit', :id => @t.id)
        expect(flash[:success]).to eq("Thanks for your submission, questions will be reviewed")
      end
    end

  end
end

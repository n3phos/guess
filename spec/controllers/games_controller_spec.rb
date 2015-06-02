require 'rails_helper'

describe GamesController do
  include ApplicationHelper

  let(:room) { Room.find('lobby') }

  before(:all) do
    create :theme # movie
    create :game_theme
    create :series_theme
  end

  after(:all) do
    Theme.destroy_all
  end

  describe "GET #new" do

    context "when there is no active game" do
      render_views

      let(:user) { create :user }

      before do
        sign_in user
      end

      it "should display game creation menu" do
        xhr :get, :new, name: 'lobby'
        expect(response).to render_template(:partial => 'shared/_new_game')
      end

    end
  end

  describe "GET #show" do
    render_views

    after(:each) do
      room.active_game = nil
    end

    context "without a game client" do

      it "should render game partial" do
        post :create, name: 'lobby'
        xhr :get, :show, name: 'lobby', id: 123
        expect(response).to render_template("create")
        expect(response).to render_template(:partial => 'shared/_game')
      end
    end

    context "with a game client" do

      it "should skip game partial rendering" do
        post :create, name: 'lobby'
        xhr :get, :show, name: 'lobby', id: 123, load_next: "true"
        expect(response).to render_template("create")
        expect(response).to_not render_template(:partial => 'shared/_game')
      end
    end

    context "while a running game" do

      # these testcases need simulation of a game that would have been
      # started by the irc bot through the ready command from the client
      before(:each) do
        post :create, name: 'lobby', categories: "Movie"
        game = Game.find(room.active_game)
        game.update(started: true)
        class Room
          def game_info
            # expected format
            "q=When was x released?,lastplay=#{Time.now.to_s},last=true"
          end
        end
      end

      it "that should be in a started state" do
        xhr :get, :show, name: 'lobby', id: 123
        expect(assigns(:game).started).to be(true)
      end

      it "should consider the passed video play time" do
        # movie theme starts initially at 0 seconds (start_seconds)
        xhr :get, :show, name: 'lobby', id: 123
        expect(assigns(:theme).start_seconds).to be > 0.5
      end
    end
  end

  describe "POST #create" do

    def is_category?(*cat)
      records = assigns(:game).gamerecords

      records.all? do |r|
        n = r.theme.category.name
        cat.include? n
      end
    end

    after(:each) do
      room.active_game = nil
    end

    context "without any categories" do
      it "selects Movie as the default category" do
        post :create, name: 'lobby', categories: ""
        expect(is_category?("Movie")).to be(true)
      end
    end

    context "with movie category" do
      it "should select movie themes" do
        post :create, name: 'lobby', categories: "Movie"
        expect(is_category?("Movie")).to be(true)
      end
    end

    context "with game category" do
      it "should select game themes" do
        post :create, name: 'lobby', categories: "Game"
        expect(is_category?("Game")).to be(true)
      end
    end

    context "with series category" do
      it "should select series themes" do
        post :create, name: 'lobby', categories: "Series"
        expect(is_category?("Series")).to be(true)
      end
    end

    context "with more than one category" do
      it "should select themes from the specific categories" do
        post :create, name: 'lobby', categories: "Series,Game"
        expect(is_category?("Series", "Game")).to be(true)
      end
    end
  end

  describe "GET #next_record" do
    before do
      # next_record requires atleast 2 themes in the game
      create :theme
      post :create, name: 'lobby', categories: "Movie"
      @game = Game.find(room.active_game)
    end

    after do
      room.active_game = nil
    end

    it "responds with json" do
      xhr :get, :next_record, name: 'lobby', id: @game.id
      expect(response.header['Content-Type']).to include("application/json")

      theme = JSON.parse(response.body)
      expect(theme["video_id"]).to_not be_nil
      expect(theme["start_seconds"]).to_not be_nil
      expect(theme["end_seconds"]).to_not be_nil
      expect(theme["img_url"]).to_not be_nil
    end
  end

  describe "PATCH #update" do
    before do
      post :create, name: 'lobby', categories: "Movie,Series,Game"
      @game = Game.find(room.active_game)
    end

    after(:each) do
      room.active_game = nil
    end

    it "should start the game" do
      patch :update, name: 'lobby', id: @game.id, started: "true"
      expect(assigns(:game).started).to be(true)
    end

    it "should finish the game" do
      patch :update, name: 'lobby', id: @game.id, started: "true"
      patch :update, name: 'lobby', id: @game.id, started: "false"

      expect(assigns(:game).started).to be(false)
      expect(assigns(:game).finished).to be(true)
    end

    it "should set the next record" do
      xhr :get, :next_record, name: 'lobby', id: @game.id
      @t1 = JSON.parse(response.body)

      patch :update, name: 'lobby', id: @game.id, current_record: "true"

      xhr :get, :next_record, name: 'lobby', id: @game.id
      @t2 = JSON.parse(response.body)

      expect(@t1["video_id"]).to_not eq(@t2["video_id"])
    end

  end
end


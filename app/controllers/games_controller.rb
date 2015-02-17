class GamesController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:update]

  def show

    @room = Room.find(params[:name])

    @game = Game.find(@room.active_game)

    if @game.started
      @theme = Game.joining_theme
    else
      @theme = @game.current.theme
    end

    if(params[:load_next] == "true")
      @load_next = true
    else
      @load_next = false
    end

    respond_to do |format|
      format.js { render 'create' }
    end

  end

  def new
    @room = Room.find(params[:name])

      respond_to do |format|
        format.js
      end

  end

  def next_record
    @game = Game.find(params[:id])

    @theme = @game.next_record_theme

    jsonify_theme

    respond_to do |format|
      format.json { render :json => @theme }
    end

  end

  def jsonify_theme()
    img_url = @theme.media_image.url(:medium)

    @theme = @theme.to_json(:only => [ :video_id, :start_seconds, :end_seconds ] )
    @theme.chomp!("}")
    @theme << ", \"img_url\":\"#{img_url}\" }"
  end

  def create

    time = Time.now

    @room = nil

    if(params[:name])
      @room = Room.find(params[:name])
    end

    if(params[:load_next] == "true")
      @load_next = true
    else
      @load_next = false
    end

    if(@room.active_game)
      render :js => "game.is_loading = false"
      return
    end

    @game = Game.new

    @game.save

    categories = []
    categories = params[:categories].split(",") unless params[:categories].empty?

    if categories.empty?
      categories << "Movie"
    end

    puts categories.inspect

    categories = Category.where(name: categories).all

    cat_ids = []

    categories.each do |cat|
      cat_ids << cat.id
    end

    puts cat_ids.inspect

    themes = Theme.where(category_id: cat_ids).all.shuffle

    Gamerecord.build_records(@game, themes)

    @theme = @game.mark_active

    @room.active_game = @game.id


    list = @game.generate_wordlist

    game_opts = { 'game_id' => "#{@game.id}", 'game_url' => request.original_url + "/#{@game.id}", 'wordlist' => list, 'load_next' => @load_next, 'created_at' => time.to_s }

    @room.setup_game(game_opts)

    #IRC.handler.clusters[:virgo].cli.setup_bot_game("virgo#bot_1", game_opts)

    respond_to do |format|
      format.js
    end

  end

  def update

    @game = Game.find(params[:id])

    if @game

      if(params[:history])

        @game.update_history(params[:history])

      end

      if(params[:current_record])

        @game.update_current

      end

      started = params[:started]

      puts "started param is: #{started}"
      puts "game started is: #{@game.started}"

      if @game.started
          if started == "false"
            puts "finding room..."
            @room = Room.find(params[:name])
            puts "deactivating game..."
            @room.active_game = nil
          end
      end

      @game.update(:started => started) unless started.nil?


      @game.save

    end

    render :nothing => true
  end


end

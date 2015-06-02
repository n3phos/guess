class GamesController < ApplicationController

  # temp solution
  skip_before_filter :verify_authenticity_token, :only => [:update]

  def show
    @room = Room.find(params[:name])

    if @room
      @game = Game.find(@room.active_game)

      # join active game
      if @game.started
        time = Time.now.utc
        @theme = @game.current.theme
        # get game info
        resp = @room.game_info

        # info for: current question, time when play was called, if last record
        # in list (true/false)
        q, last_play, last_rec = resp.split(",").map do |t|
          t.split("=")[1]
        end

        @last = last_rec
        @question = q
        last_play = Time.parse(last_play)
        # compute time difference
        diff = time - last_play
        diff += 0.5

        # add the duration this video has already been playing to the initial
        # start seconds
        @theme.start_seconds = 0 unless !@theme.start_seconds.nil?
        @theme.start_seconds += diff

      elsif(@game.finished)
        @theme = Game.dummy_theme
      else
        @theme = @game.current.theme
      end


      # skip rendering of game partial if client is already initialized
      if(params[:load_next] == "true")
        @load_next = true
      else
        @load_next = false
      end

      respond_to do |format|
        format.js { render 'create' }
      end
    end

  end

  def new
    @room = Room.find(params[:name])
    if @room
      respond_to do |format|
        format.js
      end
    end
  end

  # fetch next record
  def next_record
    @game = Game.find(params[:id])
    if @game
      @theme = @game.next_record_theme

      jsonify_theme

      respond_to do |format|
        format.json { render :json => @theme }
      end
    end
  end


  def create
    time = Time.now.utc
    @room = nil

    @room = Room.find(params[:name])

    if @room
      if(params[:load_next] == "true")
        @load_next = true
      else
        @load_next = false
      end

      if(@room.active_game)
        @active_game = Game.find(@room.active_game)
        diff = time - @active_game.created_at

        # prevent game creation if last active game is less than
        # 10 seconds old
        if(diff < 10)
          render :nothing => true
          return
        end
      end

      @game = Game.create

      categories = []
      if !params[:categories].blank?
        categories = params[:categories].split(",")
      end

      # default category
      if categories.empty?
        categories << "Movie"
      end

      categories = Category.where(name: categories).all

      puts "categories: #{categories.inspect}"

      cat_ids = []
      categories.each do |cat|
        cat_ids << cat.id
      end

      # get all themes which are in a certain category and not disabled
      themes = Theme.where(category_id: cat_ids).where(disabled: false).shuffle

      theme_records = []
      themes.each_with_index do |t, i|
        theme_records << { :theme_id => t.id, :active => false }
      end

      @game.gamerecords.create(theme_records)
      # mark first game record as active
      @theme = @game.mark_active
      # assign the game as the current active game in the room
      @room.active_game = @game.id

      # generate quiz questions
      list = @game.generate_wordlist

      game_opts = { 'game_id' => "#{@game.id}",
                    'game_url' => request.original_url + "/#{@game.id}",
                    'wordlist' => list,
                    'load_next' => @load_next,
                    'created_at' => time.to_s }

      @room.setup_game(game_opts)

      render :nothing => true
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

      if @game.started
        if started == "false"
          # deactivate the game
          @game.update(:finished => true)
        end
      end

      @game.update(:started => started) unless started.nil?
    end

    render :nothing => true
  end

  protected

  def jsonify_theme()
    img_url = @theme.media_image.url(:medium)

    @theme = @theme.to_json(:only => [ :video_id, :start_seconds, :end_seconds ] )
    @theme.chomp!("}")
    @theme << ", \"img_url\":\"#{img_url}\" }"
  end

end

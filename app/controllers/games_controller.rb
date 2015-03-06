class GamesController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:update]

  def show


    @room = Room.find(params[:name])

    @game = Game.find(@room.active_game)

    if @game.started
      time = Time.now.utc
      #@theme = Game.joining_theme
      @theme = @game.current.theme
      resp = @room.game_info
      puts "respons: #{resp}"
      q, last_play, last_rec = resp.split(",").map do |t|
        t.split("=")[1]
      end

      @last = last_rec
      @question = q
      last_play = Time.parse(last_play)
      diff = time - last_play
      puts "time: #{time}, last_play #{last_play.to_s}, diff #{diff}"
      diff += 1

      @theme.start_seconds = 0 unless !@theme.start_seconds.nil?
      @theme.start_seconds += diff
      puts "theme start seconds: #{@theme.start_seconds.to_f}"
      puts "question: #{q}"

    elsif(@game.finished)
      @theme = Game.dummy_theme
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

    time = Time.now.utc

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
      @active_game = Game.find(@room.active_game)
      diff = time - @active_game.created_at
      puts "last active game was created #{diff} seconds ago"

      if(diff < 10)
        render :js => "game.is_loading = false"
        return
      end
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

    themes = Theme.where(category_id: cat_ids).where(disabled: false).shuffle

    Gamerecord.build_records(@game, themes)

    @theme = @game.mark_active

    @room.active_game = @game.id


    list = @game.generate_wordlist

    game_opts = { 'game_id' => "#{@game.id}", 'game_url' => request.original_url + "/#{@game.id}", 'wordlist' => list, 'load_next' => @load_next, 'created_at' => time.to_s }

    @room.setup_game(game_opts)

    #IRC.handler.clusters[:virgo].cli.setup_bot_game("virgo#bot_1", game_opts)

    #respond_to do |format|
    #  format.js
    #end
    render :nothing => true

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
            #@room.active_game = nil
            @game.update(:finished => true)
          end
      end

      @game.update(:started => started) unless started.nil?


      @game.save

    end

    render :nothing => true
  end


end

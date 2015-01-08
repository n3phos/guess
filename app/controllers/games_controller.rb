class GamesController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:update]

  def show



  end

  def next_record
    @game = Game.find(params[:id])

    @theme = @game.next_record_theme

    respond_to do |format|
      format.json { render :json => @theme }
    end

  end

  def create

    @room = nil

    if(params[:name])
      @room = params[:name]
    end

    @game = Game.new

    @game.save

    themes = Theme.all.shuffle

    Gamerecord.build_records(@game, themes)

    @theme = @game.mark_active



    list = @game.generate_wordlist

    game_opts = { 'game_url' => request.original_url + "/#{@game.id}", 'wordlist' => list }

    IRC.handler.clusters[:virgo].cli.setup_bot_game("virgo#bot_1", game_opts)

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

      @game.history_id = 1337

      @game.save

    end

    render :nothing => true
  end


end

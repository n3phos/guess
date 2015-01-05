class GamesController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:update]

  def show


  end

  def create

    @room = nil

    if(params[:name])
      @room = params[:name]
    end

    @game = Game.new

    @game.save

    respond_to do |format|
      format.js
    end

  end

  def update

    @game = Game.find(params[:id])

    if @game

      @game.history_id = 1337

      @game.save

    end

    render :nothing => true
  end


end

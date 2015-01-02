class GamesController < ApplicationController

  def show


  end

  def create

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
  end


end

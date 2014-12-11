#require 'lib/room'

class RoomsController < ApplicationController
  def new


  end

  def create

    @room = Room.new(IRC.handler)

    config = { 'channel' => params[:channel], 'nick' => params[:nick] }

    @room.create(config)

    render 'new'


  end

  def join
    @room = Room.find(params[:name])

    #if !@room
      #render 'shared/errors'

    #end
    @room.join(current_user)
  end

  def leave

    #destroy(@room)
  end

  def destroy()
    @room = Room.find(params[:name])
    if @room
      @room.destroy
    end
  end

  def users
    @room = Room.find(params[:name])


    respond_to do |format|
      format.js
    end
  end

  def info
    @room = Room.find(params[:name])
    respond_to do |format|
      format.json { render json: @room.to_json(current_user) }
    end
  end

end

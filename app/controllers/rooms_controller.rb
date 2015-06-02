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
    if(current_user.nil?)
      flash[:error] = "Can't join room, please choose a nickname"
      flash[:redir_url] = request.original_url
      redirect_to :home
      return
    end

    @room = Room.find(params[:name])
    @room.join(current_user)
  end

  def leave
    @room = Room.find(params[:name])
    if @room
      @room.leave(current_user)

      if(params[:origin] == "chatcontrols")
        @redir_to_rooms = root_url + "rooms"
      else
        @redir_to_rooms = false
      end
    end
  end

  def destroy
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

  def index
    @rooms = Room.all
  end

end

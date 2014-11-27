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

end

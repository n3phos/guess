class ThemesController < ApplicationController

  def new

    @theme = Theme.new

  end

  def show

    @theme = Theme.find(params[:id])

  end

  def create

    @theme = Theme.new(theme_params)
    @theme.media_image = params[:theme][:media_image]
    @theme.save

    redirect_to @theme

  end

  private

  def theme_params
    params.require(:theme).permit(:video_id, :media_name, :category_id, :theme_name, :theme_interpret, :start_seconds, :end_seconds)
  end

end

class ThemesController < ApplicationController

  def new

    @theme = Theme.new
    3.times{ @theme.questions.build }
    @submissions = Submission.order('created_at DESC')

  end

  def show

    @theme = Theme.find(params[:id])

  end

  def create

    @theme = Theme.new(theme_params)
    @theme.media_image = params[:theme][:media_image]
    @theme.disabled = true
    @theme.save

    @theme.questions.build(params[:theme][:questions])

    Submission.create({ :user_id => current_user.id,:theme_id => @theme.id })

    redirect_to 'new'



  end

  def index

    @themes = Theme.all
    @themes = Theme.paginate(:page => params[:page], :per_page => 10)


  end

  def edit

    @theme = Theme.find(params[:id])

  end

  def update
    @theme = Theme.find(params[:id])

    @theme.update_attributes(theme_params)

    redirect_to :action => "index"
  end

  private

  def theme_params
    params.require(:theme).permit(:video_id, :media_name, :category_id, :theme_name, :theme_interpret, :start_seconds, :end_seconds, :questions_attributes => [ :ques, :answer ] )
  end

  def question_params
    params.require(:theme_questions).permit(:ques, :answer)
  end

end

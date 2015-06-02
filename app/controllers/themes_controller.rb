class ThemesController < ApplicationController

  def new
    if(current_user.nil?)
      flash[:error] = "Please choose a nickname to make a new submission"
      flash[:redir_url] = request.original_url
      redirect_to :home
      return
    end

    @theme = Theme.new
    @theme.start_seconds = 0
    @theme.end_seconds = 0

    3.times{ @theme.questions.build }
    @submissions = Submission.order('created_at DESC')
  end

  def show
    @theme = Theme.find(params[:id])
  end

  def create
    if(params[:theme])
      @theme = Theme.new(filter_questions(theme_params))

      @theme.media_image = params[:theme][:media_image]
      @theme.disabled = true

      if @theme.save
        Submission.create({ :user_id => current_user.id,:theme_id => @theme.id })
        redirect_to '/themes/new'
      else
        @submissions = Submission.order('created_at DESC')
        3.times{ @theme.questions.build }
        render 'new'
      end
    end
  end

  def index
    @themes = Theme.where(disabled: false).paginate(:page => params[:page], :per_page => 10)
  end

  def edit
    @theme = Theme.find(params[:id])
    @new_questions = []
    3.times{ @new_questions << @theme.questions.build }
  end

  def update
    @theme = Theme.find(params[:id])

    qs = filter_questions(theme_question_params)

    if(@theme.update_attributes(qs))
      flash[:success] = "Thanks for your submission, questions will be reviewed"
      redirect_to :action => "edit"
    else
      redirect_to :action => "edit"
    end
  end

  def destroy
    @theme = Theme.find(params[:id])
    @theme.destroy

    redirect_to "/themes"
  end

  private

  def theme_params
    params.require(:theme).permit(:video_id, :media_name, :media_image, :disabled, :category_id, 
                                  :theme_name, :theme_interpret, :start_seconds, :end_seconds, :questions_attributes => [ :ques, :answer ] )
  end

  def theme_question_params
    params.require(:theme).permit(:questions_attributes => [:ques, :answer])
  end

  def filter_questions(par)
    if(par[:questions_attributes])
      par[:questions_attributes].delete_if do |k, v|
        v['ques'].blank? || v['answer'].blank?
      end

    par

    end
  end

end

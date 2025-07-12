class DreamsController < ApplicationController
  def mydreams
    @dreams = current_user.dreams
  end

  def index
    @dreams = Dream.where(private: false)
  end

  def new
    @dream = Dream.new
  end

  def create
    @dream = current_user.dreams.build(dream_params)
    if @dream.save
      redirect_to mydreams_path, notice: "Rêve créé avec succès"
    else
      render :new
    end
  end

  def show
    @dream = Dream.find(params[:id])
  end

  private

  def dream_params
    params.require(:dream).permit(:title, :tags, :private)
  end

end

class DreamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dream, only: [:show, :edit, :update, :destroy, :transcribe]

  def mydreams
    @dreams = current_user.dreams.order(created_at: :desc)
  end

def index
  @dreams = Dream.where(private: [false, nil]).includes(:user, :transcription)

  # Search in title, tags AND transcription content
  if params[:search].present?
    search_term = "%#{params[:search]}%"
    @dreams = @dreams.joins(:transcription).where(
      "dreams.title ILIKE ? OR dreams.tags ILIKE ? OR transcriptions.content ILIKE ?",
      search_term, search_term, search_term
    )
  end

  # Filter by specific tag
  if params[:tag].present?
    @dreams = @dreams.where("tags ILIKE ?", "%#{params[:tag]}%")
  end

  @dreams = @dreams.order(created_at: :desc)

  # Get all unique tags for dropdown
  @available_tags = Dream.where(private: [false, nil])
                        .where.not(tags: [nil, ''])
                        .pluck(:tags)
                        .flat_map { |tags| tags.split(',').map(&:strip) }
                        .uniq
                        .sort
end

  def new
    @dream = Dream.new
    @dream.build_transcription
  end

  def create
    @dream = current_user.dreams.build(dream_params)

    if @dream.save
      respond_to do |format|
        format.html { redirect_to mydreams_path, notice: "Dream created successfully!" }
        format.json {
          render json: {
            success: true,
            id: @dream.id,
            message: "Dream saved successfully!",
          }, status: :created
        }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: { success: false, errors: @dream.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

  def edit
    @dream.build_transcription unless @dream.transcription
  end

  def update
    if @dream.update(dream_params)
      redirect_to mydreams_path, notice: "Dream updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @dream.destroy
    redirect_to mydreams_path, notice: "Dream deleted successfully"
  end

  def transcribe
    unless @dream.audio.attached?
      redirect_to mydreams_path, alert: "No audio file found for transcription"
      return
    end

    if @dream.transcription.present?
      redirect_to dream_transcription_path(@dream), notice: "Transcription already exists"
      return
    end

    # Appel du service de transcription
    service = TranscriptionService.new(dream: @dream)
    result = service.transcribe

    if result[:success]
      redirect_to dream_transcription_path(@dream),
                  notice: "Transcription completed successfully!"
    else
      redirect_to mydreams_path,
                  alert: result[:message]
    end
  end

  protect_from_forgery except: :upload_audio

  def upload_audio
    title = params[:title].presence || "Untitled voice dream #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"

    dream = current_user.dreams.create!(
      title: title,
      private: true
    )

    dream.audio.attach(params[:audio])

    render json: { success: true, id: dream.id }, status: :ok

  rescue => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end

  private

  def set_dream
    @dream = current_user.dreams.find(params[:id])
  end

  def dream_params
    params.require(:dream).permit(
      :title,
      :tags,
      :private,
      :audio,
      transcription_attributes: [
        :id,           # indispensable pour modifier une transcription existante
        :content,
        :dream_type,
        :mood,
        :tag,
        :rating
      ]
    )
  end
end

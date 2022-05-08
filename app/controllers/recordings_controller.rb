class RecordingsController < ApplicationController
  before_action :set_snapshot
  before_action :set_recording, only: %i[ show edit update destroy ]

  # GET /recordings or /recordings.json
  def index
    @recordings = @snapshot.recordings
  end

  # GET /recordings/1 or /recordings/1.json
  def show
  end

  # GET /recordings/new
  def new
    @recording = @snapshot.recordings.new
  end

  # GET /recordings/1/edit
  def edit
  end

  # POST /recordings or /recordings.json
  def create
    
    @recording = @snapshot.recordings.new(recording_params)

    respond_to do |format|
      if @recording.save
        format.html { redirect_to @recording.snapshot, notice: "Recording was successfully created." }
        format.json { render :show, status: :created, location: @recording }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @recording.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recordings/1 or /recordings/1.json
  def update
    respond_to do |format|
      if @recording.update(recording_params)
        format.html { redirect_to @recording, notice: "Recording was successfully updated." }
        format.json { render :show, status: :ok, location: @recording }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @recording.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recordings/1 or /recordings/1.json
  def destroy
    @recording.destroy
    respond_to do |format|
      format.html { redirect_to recordings_url, notice: "Recording was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_snapshot
      @snapshot = Snapshot.find(params[:id])
    end

    def set_recording
      @recording = @snapshot.recordings.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def recording_params
      params.require(:recording).permit(:year, :month, :cash, :equities, :expenses, :income, :liabilities)
    end
end

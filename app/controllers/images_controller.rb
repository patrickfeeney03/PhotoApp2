class ImagesController < ApplicationController
  before_action :set_image, only: %i[ show edit update destroy ]
  before_action lambda { resize_before_save(image_params[:picture], 600, 600) }, only: [:create, :update]
  before_action :authenticate_user!, except: %i[show index]
  before_action :authorize_image, only: [:edit, :destroy, :update]

  # GET /images or /images.json
  def index
    @images = Image.all
  end

  # GET /images/1 or /images/1.json
  def show

  end

  # GET /images/new
  def new
    @image = Image.new
  end

  # GET /images/1/edit
  def edit

  end

  # POST /images or /images.json
  def create
    @image = Image.new(image_params)
    @image.user = current_user

    respond_to do |format|
      if @image.save
        format.html { redirect_to image_url(@image), notice: "Image was successfully created." }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /images/1 or /images/1.json
  def update
    respond_to do |format|
      if @image.update(image_params)
        format.html { redirect_to image_url(@image), notice: "Image was successfully updated." }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1 or /images/1.json
  def destroy
    @image.destroy!

    respond_to do |format|
      format.html { redirect_to images_url, notice: "Image was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_image
    @image = Image.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def image_params
    params.require(:image).permit(:title, :picture)
  end

  def resize_before_save(image_param, width, height)
    # Return if image_param is false or nil
    return unless image_param

    ImageProcessing::MiniMagick
      .source(image_param)
      .resize_to_fit(width, height)
      .call(destination: image_param.tempfile.path)
  end

  def authorize_image
    # Retrieve the image with the current id
    @image = Image.find(params[:id])
    # If the user is not the same don't allow editing
    unless current_user == @image.user
      redirect_to image_path(@image), notice: "You can only edit images you have created."
    end
  end
end

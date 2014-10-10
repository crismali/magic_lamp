class ApplesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_apple, only: [:show, :edit, :update, :destroy]

  # GET /apples
  def index
    @apples = Apple.all
  end

  # GET /apples/1
  def show
  end

  # GET /apples/new
  def new
    @apple = Apple.new
  end

  # GET /apples/1/edit
  def edit
  end

  # POST /apples
  def create
    @apple = Apple.new(apple_params)

    if @apple.save
      redirect_to @apple, notice: 'Apple was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /apples/1
  def update
    if @apple.update(apple_params)
      redirect_to @apple, notice: 'Apple was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /apples/1
  def destroy
    @apple.destroy
    redirect_to apples_url, notice: 'Apple was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_apple
      @apple = Apple.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def apple_params
      params[:apple]
    end
end

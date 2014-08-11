class ThingsController < ApplicationController
  before_action :set_thing, only: [:show, :edit, :update, :destroy]

  # GET /things
  def index
    @things = Thing.all
  end

  # GET /things/1
  def show
  end

  # GET /things/new
  def new
    @thing = Thing.new
  end

  # GET /things/1/edit
  def edit
  end

  # POST /things
  def create
    @thing = Thing.new(thing_params)

    if @thing.save
      redirect_to @thing, notice: 'Thing was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /things/1
  def update
    if @thing.update(thing_params)
      redirect_to @thing, notice: 'Thing was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /things/1
  def destroy
    @thing.destroy
    redirect_to things_url, notice: 'Thing was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_thing
      @thing = Thing.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def thing_params
      params[:thing]
    end
end

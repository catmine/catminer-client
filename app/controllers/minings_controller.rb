class MiningsController < ApplicationController
  before_action :set_mining, only: [:show, :edit, :update, :destroy]

  # GET /minings
  # GET /minings.json
  def index
    @page_title = Mining

    rig = Rig.default
    @mining = rig.minings.last

    rig.stop_mining if @mining.blank?

    @mining_logs = rig.mining_logs.order('id DESC').limit(1000)
  end

  # GET /minings/1
  # GET /minings/1.json
  def show
  end

  # GET /minings/new
  def new
    @page_title = 'Set mining'
    @mining = Mining.new rig: Rig.default, code: 1
  end

  # GET /minings/1/edit
  def edit
  end

  # POST /minings
  # POST /minings.json
  def create
    @mining = Mining.new(mining_params)

    respond_to do |format|
      if @mining.save
        format.html { redirect_to minings_path, notice: 'Mining has been set.' }
        format.json { render :show, status: :created, location: minings_path }
      else
        format.html { render :new }
        format.json { render json: @mining.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /minings/1
  # PATCH/PUT /minings/1.json
  def update
    respond_to do |format|
      if @mining.update(mining_params)
        format.html { redirect_to @mining, notice: 'Mining has been set.' }
        format.json { render :show, status: :ok, location: @mining }
      else
        format.html { render :edit }
        format.json { render json: @mining.errors, status: :unprocessable_entity }
      end
    end
  end

  def stop
    rig = Rig.default
    rig.stop_mining

    flash[:notice] = 'Mining has been stop.'
    redirect_to minings_path
  end

  def restart
    rig = Rig.default
    rig.restart_miner

    flash[:notice] = 'Miner has been restart.'
    redirect_to minings_path
  end

  # DELETE /minings/1
  # DELETE /minings/1.json
  def destroy
    @mining.destroy
    respond_to do |format|
      format.html { redirect_to minings_url, notice: 'Mining was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mining
      @mining = Mining.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mining_params
      params.require(:mining).permit(:rig_id, :code, :miner, :arg)
    end
end

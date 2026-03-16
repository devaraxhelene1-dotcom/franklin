class StepsController < ApplicationController
  before_action :set_campaign_and_step

  def show
  end

  def edit
  end

  def toggle_status
    new_status = @step.status == "done" ? "pending" : "done"
    @step.update!(status: new_status)
    redirect_to campaign_step_path(@campaign, @step)
  end

  def update
    if @step.update(step_params)
      redirect_to edit_campaign_step_path(@campaign, @step), notice: "Step modifié avec succès"
    else
      render :edit
    end
  end

  private

  def set_campaign_and_step
    @campaign = current_user.campaigns.find(params[:campaign_id])
    @step = @campaign.steps.find(params[:id])
  end

  def step_params
    params.require(:step).permit(:status)
  end
end

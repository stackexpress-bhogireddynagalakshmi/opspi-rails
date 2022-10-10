class Spree::Admin::Sites::BackupController < ApplicationController
  before_action :set_user_domain

  def update
    @website = @user_domain.user_website
    if params[:user_website][:enable_backup] == '1' 
      # backup_api.start_backup(@website.id)
    else
      backup_api.stop_backup(@website.id)
    end
  end

  def index
    @website = @user_domain.user_website
    result = backup_api.all(@website.id)

    if result[:success] == true
      @backups = result[:response].response
    else
      @backups = []
    end

    render :partial=> 'index',locals: {backups: @backups }, layout: false
  end

  private

  def backup_api
    if @user_domain.windows?
      #TODO yet to implement
    else
      current_spree_user.isp_config.site_backup
    end
  end
end

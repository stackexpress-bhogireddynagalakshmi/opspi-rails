class Spree::Admin::Sites::BackupController < ApplicationController
  before_action :set_user_domain

  def update
    @website = @user_domain.user_website
    if params[:user_website][:enable_backup] == '1' 
      backup_api.start_backup(@website.id)
    else
      backup_api.stop_backup(@website.id)
    end
  end

  def index
    @website = @user_domain.user_website
    result = backup_api.all(@website.id)

    if result[:success] == true && @user_domain.linux?

    elsif result[:success] == true && @user_domain.windows?
      res = result[:response].body
      @array_of_string = res[:get_backup_content_summary_response][:get_backup_content_summary_result][:key_value_array][:array_of_string] rescue []
      
      # website_backed_up = array_of_string[1][:string][1].include?(@user_domain.domain) rescue false
      # database_backed_up = (array_of_string[3][:string][1].split(",") & @user_domain.user_databases.pluck(:database_name)).size == @user.user_databases.size
      # @backups = result[:response].response
    else
      @backups = []
    end

    render :partial=> 'index',locals: {backups: @backups }, layout: false
  end

  private

  def backup_api
    if @user_domain.windows?
      #TODO yet to implement
      current_spree_user.solid_cp.site_backup
    else
      current_spree_user.isp_config.site_backup
    end
  end
end

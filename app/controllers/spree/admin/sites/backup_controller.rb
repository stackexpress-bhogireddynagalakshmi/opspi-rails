class Spree::Admin::Sites::BackupController < ApplicationController
  before_action :set_user_domain
  before_action :set_website

  def update
     @website = @user_domain.user_website
     backup_api.update(@website.id, {})
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

class Spree::Admin::IspConfigController < Spree::Admin::BaseController
  helper Spree::Admin::NavigationHelper

  def domains
    response = mail_domain.all || []
    if response[:success]
      @domains  = response[:response].response
    else
      @domains = []
    end
  end

  def domain
    domain = current_mail_domain
    if domain.present? #edit,delete.update
      if request.put?
        @response  = mail_domain.update(domain.isp_config_mail_domain_id, mail_domain_params)
        set_flash
        redirect_to domains_admin_isp_config_index_path
      elsif  request.delete?
        @response  = mail_domain.destroy(domain.isp_config_mail_domain_id)
        set_flash
        redirect_to domains_admin_isp_config_index_path
      elsif request.get?
        @response = mail_domain.find(domain.isp_config_mail_domain_id)
        @mail_domain = @response[:response].response  if @response[:success].present?
      end
    else #create , #new
       if request.post?
         @response  = mail_domain.create(mail_domain_params)
         set_flash
         redirect_to domains_admin_isp_config_index_path
       end
    end
  end

  def mailboxes
    response = mail_user.all || []
    if response[:success]
      @mailboxes  = response[:response].response
    else
      @mailboxes = []
    end
  end

  def mailbox
    mailbox = current_mail_box

    if mailbox.present? #edit,delete.update
      if request.put?
        @response  = mail_user.update(mailbox.isp_config_mailuser_id, mail_user_params)
        set_flash
        redirect_to mailboxes_admin_isp_config_index_path
      elsif  request.delete?
        @response  = mail_user.destroy(mailbox.isp_config_mailuser_id)
        set_flash
        redirect_to mailboxes_admin_isp_config_index_path
      elsif request.get?
        @response = mail_user.find(mailbox.isp_config_mailuser_id)
        @mail_box = @response[:response].response  if @response[:success].present?
      end
    else #create , #new
       if request.post?
         @response  = mail_user.create(mail_domain_params)
         set_flash
         redirect_to mailboxes_admin_isp_config_index_path
       end
    end
  end

  private
  def set_flash
    if @response[:success] 
      flash[:success] = @response[:message]
    else
      flash[:error] = @response[:message] 
    end
  end

  #mail domains
  def mail_domain_params
    params.require("domain").permit(:domain,:active)
  end

  def mail_domain
    current_spree_user.isp_config.mail_domain
  end

  def current_mail_domain
    current_spree_user.mail_domains.find_by_isp_config_mail_domain_id(params[:domain_id])
  end

  # mailboxes
  def mail_user_params
    params.require("mailuser").permit(:domain,:active)
  end

  def mail_user
    current_spree_user.isp_config.mail_user
  end

  def current_mail_box
    current_spree_user.mail_users.find_by_isp_config_mailuser_id(params[:mailuser_id])
  end

end

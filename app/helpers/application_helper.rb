# frozen_string_literal: true

module ApplicationHelper
  def get_spree_roles(user)
    if user.superadmin?
      Spree::Role.all
    elsif user.store_admin?
      Spree::Role.where(name: ['user'])
    end
  end

  def current_admin_tenant?
    current_store.account.admin_tenant?
  end

  def render_new_tenant_information(order)
    text = ""
    if current_admin_tenant?
      user = TenantManager::TenantHelper.unscoped_query { order.user }
      text += link_to user.account.domain, get_tenant_host_for_resource_path(user), target: '_blank'
    end
  end

  def plan_type_values(user)
    if user.superadmin?
      superadmin_plans(user)
    elsif user.store_admin?
      reseller_plans(user)
    elsif  user.end_user?
      get_purchased_plans.uniq.collect { |x| [x.titleize, x] }
    end
  end

  def reseller_plans(user)
    plans = []
    
    if user.have_reseller_plan? && user.isp_config_id.present? && user.solid_cp_id.present?
      plans = [['Windows Hosting', 'windows'], ['Linux Hosting', 'linux']]
    end

    plans << ['Hsphere Plan', 'hsphere'] if get_purchased_plans.include?('hsphere')
    plans || []
  end

  def window_server_type
    [['Windows', 'windows']]
  end

  def linux_server_type
    [['Linux', 'linux']]
  end

  def superadmin_plans(_user)
    [
      ['Reseller Hosting Plan', 'reseller_plan'],
      ['Hsphere Plan', 'hsphere'],
      ['Domain Reselling Plan', 'domain']
    ]
  end

  def get_purchased_plans
    TenantManager::TenantHelper.unscoped_query do
      current_spree_user.orders.collect do |o|
        o.products.pluck(:server_type)
      end.flatten
    end
  end

  def current_tenant
    current_store.account || TenantManager::TenantHelper.current_tenant
  end

  def format_date(date)
    return unless date

    date.strftime("%Y-%m-%d")
  end

  def format_date_with_century(date)
    return unless date

    date.strftime("%Y-%m-%d")
  end

  def current_available_payment_methods(user)
    if user.present? && user.store_admin?
      TenantManager::TenantHelper.unscoped_query do
        TenantManager::TenantHelper.admin_tenant.payment_methods.available_on_front_end.select do |pm|
          pm.available_for_order?(self)
        end
      end
    else
      current_tenant.payment_methods.available_on_front_end.select { |pm| pm.available_for_order?(self) }
    end
  end

  def link_to_with_protocol(text, url, opts = {})
    protocol = request.ssl? ? 'https://' : 'http://'

    link_to text, "#{protocol}#{url}", opts
  end

  def render_domain_status(value)
    status = value["status"] == 'available' ? "<span class='available'>Available</span>" : "<span class='not-available'>Not Available</span>"

    status.html_safe
  end

  def render_domain_name(product, line_item)
    return nil unless product.domain?
    return nil unless line_item.domain.present?

    line_item.domain + ": #{line_item.validity} Years"
  end

  def generate_id_from_key(key)
    return nil if key.blank?

    key.gsub('.', '_')
  end

  def get_priority_dropdown
    [
      ['1 - lowest', 1],
      [2, 2],
      [3, 3],
      [4, 4],
      ['5 - medium', 5],
      [6, 6],
      [7, 7],
      [8, 8],
      [9, 9],
      ['10 - highest', 10]
    ]
  end

  def get_web_mail_client_url
    ENV['ISP_CONFIG_WEB_MAIL_HOST'].presence
  end

  def get_mail_domians
    domains = current_spree_user.isp_config.mail_domain.all
    domains[:response].response.collect(&:domain)
  rescue Exception => e
    Rails.logger.info { e.message }
    []
  end

  def get_web_domians
    domains = current_spree_user.isp_config.website.all
    domains[:response].response.collect { |x| [x.domain, x.domain_id] }
  rescue Exception => e
    Rails.logger.info { e.message }
    []
  end

  def get_dns_domains
    domains = current_spree_user.isp_config.hosted_zone.all_zones
    domains[:response].response.collect { |x| x.origin.chomp(".") }
  rescue Exception => e
    Rails.logger.info { e.message }
    []
  end

  def current_domain_chat_widget
    return ENV['CHATWOOT_ADMIN_WEBSITE_TOKEN'] if current_domain.eql?(ENV['BASE_DOMAIN'])

    store_account_id = Spree::Store.where(url: current_domain).pluck(:account_id).first
    chatwoot_user = ChatwootUser.where(store_account_id: store_account_id).first
    return nil if chatwoot_user.nil?

    chatwoot_user.website_token
    # return nil if current_spree_user.nil?
    # chatwoot_user = ChatwootUser.where(store_account_id: current_spree_user.account.id).first
    # return nil if chatwoot_user.nil?
    # return ENV['CHATWOOT_ADMIN_WEBSITE_TOKEN'] if current_spree_user.store_admin?
    # chatwoot_user.website_token
  end

  def current_domain
    Addressable::URI.parse(request.original_url).host
  end

  def months_dropdown
    [
      ['1 Month',  1],
      ['2 Months', 2],
      ['3 Months', 3],
      ['4 Months', 4],
      ['5 Months', 5],
      ['6 Months', 6],
      ['7 Months', 7],
      ['8 Months', 8],
      ['9 Months', 9],
      ['10 Months', 10],
      ['11 Months', 11],
      ['12 Months', 12]
    ]
  end

  def get_data_for_task(job)
    case job[:type]
    when 'create_dns_domain'
      job[:data][:name]
    when 'create_dns_record'
      "#{job[:data][:type]} Record - #{job[:data][:name]}"
    when 'create_web_domain'
      job[:data][:domain]
    when 'create_mail_domain'
      job[:data][:domain]
    when 'create_mail_box'
      job[:data][:email]
    when 'create_ftp_account'
      job[:data][:username]
    when 'create_database'
      job[:data][:database_username]
    else
      "Unknown task type"
    end
  end

  def get_task_status(job)
    return nil if job[:sidekiq_job_id].blank?

    status = ActiveJob::Status.get(job[:sidekiq_job_id])

    status = if status[:blocked]
               :queued
             else
               status[:status]
             end

    return status unless status == :completed

    "<i class='fa fa-check'></i> #{status}".html_safe
  end

  def get_sidekiq_job_status(job)
    return nil if job[:sidekiq_job_id].blank?

    ActiveJob::Status.get(job[:sidekiq_job_id])
  end

  def get_wizard_status(batch_job)
    statuses = []
    batch_job.each do |job|
      statuses << get_task_status(job)
    end
    return 'Failed' if statuses.compact.size.zero?

    (statuses.compact & %i[failed working queued]).size.positive? ? 'In Progress' : 'Completed'
  end

  def get_hsphere_control_panel
    HsphereClusterConfig.where(cluster_id: current_spree_user.hsphere_cluster_id).pluck(:value).first
  end

  def plan_type_label(product)
    if product.windows?
       I18n.t(:windows_hosting_plan)
    elsif product.linux?
      I18n.t(:linux_hosting_plan)
    elsif product.reseller_plan?
      I18n.t(:reseller_plan)
    elsif product.domain?
      I18n.t(:domain_plan)
    end
  end

  def get_reseller_products
    TenantManager::TenantHelper.unscoped_query{ Spree::Product.reseller_plan.where(subscribable: true, visible: true) }
  end

  def get_database_types(user)
    types = []

     if (user.isp_config_id.present? && user.have_linux_access?) || (user.solid_cp_id.present? && user.have_windows_access?)
      types << ['MySQL','my_sql']
    end
    
    if user.solid_cp_id.present? && user.have_windows_access?
      types << ['MsSQL2019','ms_sql2019'] 
    end

    types
  end

  def user_data_by_id(id)
    Spree::User.where(id: id).first
  end


  def html_boolean(boolean, opts={})
    if opts[:reverse] == true
      if boolean == true
         '<i class="fe fe-x-circle red"></i>'.html_safe
      else
        '<i class="fe fe-check-circle green"></i>'.html_safe
      end
    else
      if boolean == true
        '<i class="fe fe-check-circle green"></i>'.html_safe
      else
        '<i class="fe fe-x-circle red"></i>'.html_safe
      end
    end
  end

  def map_isp_config_error_msg(msg)
    if msg.include?("email_error_isemail")
      I18n.t("isp_config.errors.email_error_isemail")
    else
      msg
    end
  end

  def linux_db_prefix(user)
    "c#{user.isp_config_id}"
  end

  def windows_db_prefix(user)
    "c#{user.solid_cp_id}"
  end
end

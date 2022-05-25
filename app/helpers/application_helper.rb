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
    TenantManager::TenantHelper.current_admin_tenant?
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
      Spree::Product.server_types.keys
    elsif user.store_admin?
      TenantManager::TenantHelper.unscoped_query do
        current_spree_user.orders.collect do |o|
          o.products.pluck(:server_type)
        end.flatten
      end.uniq
    end

    # ["hsphere"]
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

  def  get_dns_domains
    begin
      domains = current_spree_user.isp_config.hosted_zone.all_zones
      domains[:response].response.collect{|x| x.origin.chomp(".")}
    rescue Exception => e
      Rails.logger.info{ e.message}
      []
    end
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
      job[:data][:database_name]
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

  def get_wizard_status(batch_job)
    statuses = []
    batch_job.each do |job|
      statuses << get_task_status(job)
    end
    (statuses.compact & %i[failed working queued]).size.positive? ? 'In Progress' : 'Completed'
  end
end

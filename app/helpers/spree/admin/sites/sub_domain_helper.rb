module Spree::Admin::Sites::SubDomainHelper
  def get_sub_domain_name(websites, params)
    return "" if websites.blank?
    begin
      website = websites.select{|w| w if (w.domain_id == params.parent_domain_id) }
      domain = website.first.domain
      params.domain.slice! ("."+domain)
      params.domain
    rescue
      ""
    end
  end
end

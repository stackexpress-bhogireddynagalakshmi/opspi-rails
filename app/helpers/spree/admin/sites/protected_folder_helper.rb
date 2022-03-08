module Spree::Admin::Sites::ProtectedFolderHelper
  def get_website_name(parent_domain_id, websites)
    return parent_domain_id if websites.blank?
    begin
      website = websites.select{|w| w if (w.domain_id == parent_domain_id) }
      website.first.domain
    rescue
      parent_domain_id
    end
  end
end

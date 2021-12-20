module Spree::Admin::DomainRegistrationsHelper

  def get_tld_pricing(key,tld_pricing)
    dot_key = "dot#{key.split(".")[-1]}"

    return 10.0  if tld_pricing[dot_key].blank?

    return tld_pricing[dot_key]["addnewdomain"]["1"].to_f
  end
end

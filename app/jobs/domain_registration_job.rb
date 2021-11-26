class DomainRegistrationJob < ApplicationJob
  queue_as :default

  def perform(line_item,opts= {})
    Rails.logger.info { "Attempting to Register the Domain #{line_item.domain} with ResellerClub"}

    @user = line_item.order.user


    if @user.reseller_club_customer_id.blank?
      success  = DnsManager::ResellerClub::CustomerCreator.new(@user).call
    
      raise "Unable to create ResllerClub Customer: #{response.error}" unless success
    end


    if @user.reseller_club_contact_id.blank?
      success  = DnsManager::ResellerClub::ContactCreator.new(@user).call
      

      raise "Unable to create ResllerClub Contact:  #{response.error}" unless response.success
    end

    domain = line_item.domain
    validity = line_item.validity.to_s
    protect_privacy = line_item.protect_privacy.to_s


    success = DnsManager::ResellerClub::DomainRegistrar.new(
                @user, {domain: domain,validity: validity,protect_privacy: protect_privacy}
              ).call

    

    raise "Unable to RegisterDomain:  #{response.error}"  unless response.success

  end


end
class DomainRegistrationJob < ApplicationJob
  queue_as :default

  def perform(line_item,opts= {})
    Rails.logger.info { "Attempting to Register the Domain #{line_item.domain} with ResellerClub"}

    @user = line_item.order.user


    if @user.reseller_club_customer_id.blank?
      @result  = DnsManager::ResellerClub::CustomerCreator.new(@user).call
      
      raise "Unable to create ResllerClub Customer: #{@result.inspect}"  unless  success?
    end


    if @user.reseller_club_contact_id.blank?
       @result   = DnsManager::ResellerClub::ContactCreator.new(@user).call
      
      raise "Unable to create ResllerClub Contact:  #{@result.inspect}" unless  success?
    end

    domain = line_item.domain
    validity = line_item.validity.to_s
    protect_privacy = line_item.protect_privacy.to_s


     @result  = DnsManager::ResellerClub::DomainRegistrar.new(
                @user, {domain: domain,validity: validity,protect_privacy: protect_privacy,line_item: line_item}
              ).call

  
    raise "Unable to RegisterDomain:  #{@result.inspect}"   unless  success?
  end


  def success?()
    return
    @result[:success] == true
  end


end
class DomainRegistrationJob < ApplicationJob
  queue_as :default

  def perform(line_item,opts= {})
    domain = line_item.domain
    validity = line_item.validity.to_s
    protect_privacy = line_item.protect_privacy.to_s

    Rails.logger.info { "Attempting to Register the Domain #{line_item.domain} with ResellerClub"}

    response = ResellerClub::Domain.register("domain-name" => domain, "years" => validity, "ns" => ["ns1.domain.com", "ns2.domain.com"], "customer_id" => "8989245", "reg-contact-id" => "25052632", "admin-contact-id" => "25052632", "tech-contact-id" => "25052632", "billing-contact-id" => "25052632", "invoice-option" => "NoInvoice", "protect-privacy" => protect_privacy, "attr-name1" => "idnLanguageCode", "attr-value1" => "aze")

  end
end
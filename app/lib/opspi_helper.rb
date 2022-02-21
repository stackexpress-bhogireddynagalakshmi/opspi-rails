# frozen_string_literal: true

class OpspiHelper
  def self.reserved_domains
    ENV.fetch("RESERVED_DOMAINS").try("split", ' ')
  rescue StandardError
    []
  end

  def self.admin_domain
    ENV.fetch("ADMIN_DOMAIN")
  rescue StandardError
    nil
  end

  def self.admin_domain
    ENV.fetch("BASE_DOMAIN")
  rescue StandardError
    nil
  end
end

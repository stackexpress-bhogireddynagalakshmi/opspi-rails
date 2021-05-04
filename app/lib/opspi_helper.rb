class OpspiHelper 
	def self.reserved_domains
		ENV.fetch("RESERVED_DOMAINS").try("split",' ') rescue []
	end

	def admin_domain
		ENV.fetch("ADMIN_DOMAIN") rescue nil
	end
end

module DnsManager  
  class CnameResolver
    include Dnsruby

    attr_reader :host
    def initialize(host)
      @host = host
      @res = Dnsruby::Resolver.new
      @ret = @res.query(host, Types.CNAME)
    end


    def cname
      return if @ret.answer.blank?

      @ret.answer[0].domainname.to_s
    end

    def cname_configured?
      return false unless cname

      cname == ENV['CNAME_POINTER_DOMAIN']     
    end

  end
end



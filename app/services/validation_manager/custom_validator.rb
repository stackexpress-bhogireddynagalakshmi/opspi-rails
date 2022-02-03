module ValidationManager
    class CustomValidator < ApplicationService
     attr_reader :record_params,:type, :reg
    
      def initialize(record_params, options = {})
        @record_params = record_params
        @type = options[:type]
        @reg = options[:reg]
      end
  
      def call
         res = validate_mandatory_fields 
  
         return res if res[0] == false
  
         validate_content    
      end
  
      def validate_content
        return [true] if type.eql?"TXT"
        matchers = @record_params[:data].match(reg)
        
        return [false, "Invalid Content for #{@type} Record"] if matchers.blank?
  
        return [true]
      end
  
      def validate_mandatory_fields
        if type.eql?"A"
          return [false, I18n.t('isp_config.required_field_missing')] if record_params[:type].blank? || record_params[:name].blank? || record_params[:ipv4].blank?
  
          return [true]
        elsif type.eql?"AAAA"
          return [false, I18n.t('isp_config.required_field_missing')] if record_params[:type].blank? || record_params[:name].blank? || record_params[:ipv6].blank?
  
          return [true]
        elsif type.eql?"CNAME"
          return [false, I18n.t('isp_config.required_field_missing')] if record_params[:type].blank? || record_params[:name].blank? || record_params[:target].blank?
  
          return [true]
        elsif type.eql?"MX"
          return [false, I18n.t('isp_config.required_field_missing')] if record_params[:type].blank? || record_params[:name].blank? || record_params[:mailserver].blank? || record_params[:priority].blank?
  
          return [true]
        elsif type.eql?"NS"
          return [false, I18n.t('isp_config.required_field_missing')] if record_params[:type].blank? || record_params[:name].blank? || record_params[:nameserver].blank?
  
          return [true]
        elsif type.eql?"TXT"
          return [false, I18n.t('isp_config.required_field_missing')] if record_params[:type].blank? || record_params[:name].blank? || record_params[:content].blank?
  
          return [true]
        end
        
      end
  
    end
  end
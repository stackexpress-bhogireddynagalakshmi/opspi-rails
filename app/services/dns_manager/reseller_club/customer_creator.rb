module DnsManager  
  module ResellerClub
    class CustomerCreator < ApplicationService
      attr_reader :user

      def initialize(user,opts={})
        @user   = user
      end

      def call
        return nil if user.reseller_club_customer_id.present?

        address = user.addresses.first
        set_password
        
        response = ::ResellerClub::Customer.v2_signup(customer_params)

        if response[:success]
          user.update_column(:reseller_club_customer_id,response[:response]["code"])
        end

        response

      end


      private


      def customer_params
        address = user.addresses.first
        set_password
        {
          "username"        =>  user.email,
          "email"          =>  user.email,
          "passwd"          =>  get_password,
          "name"            =>  user.first_name || "",
          "company"         =>  user.company_name || "" ,
          "address-line-1"  =>  address&.address1 || "",
          "city"            =>  address&.city || "",
          "state"           =>  state(address&.state&.name )|| "",
          "country"         =>  address&.country&.iso || "",
          "zipcode"         =>  address&.zipcode || "",
          "phone-cc"        =>  sanitize_country_code(address.country_code),
          "phone"           =>  sanitize_phone(address&.phone),
          "lang-pref"       => "en"
          
        }
      end

      def set_password
        AppManager::RedisWrapper.set(reseller_club_password_key,generate_password)
      end

      def get_password
        AppManager::RedisWrapper.get(reseller_club_password_key)
      end

      def reseller_club_password_key
        user.reseller_club_password_key
      end

      def state(name)
        return "" if name.blank?

        name.gsub(" ","-")
      end

      def sanitize_phone(phone)
        return "" if phone.blank?

        phone.delete('^0-9')
      end

      def sanitize_country_code(code)
        return "1"
        
        code.delete('^0-9')
      end

      def generate_password
       
        lower_chars   = 'abcdefghijklmnopqrstuvwxyz'
        upper_chars   = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        numbers       = '1234567890'
        special_chars = '~*!@$#%_+.?:,{})'

        password = lower_chars.split(//).sample
        password = password + special_chars.split(//).sample
        password = password + upper_chars.split(//).sample     
        password = password + numbers.split(//).sample
  
        chars = '~*!@$#%_+.?:,{})abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'

        begin
          char = chars[rand(chars.size)]
          password << char if password[-1] != char
        end while password.length < 15
        password
      end



    end
  end
end


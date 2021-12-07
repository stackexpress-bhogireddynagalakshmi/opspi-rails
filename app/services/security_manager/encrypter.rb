require 'openssl'
require 'base64'

module SecurityManager
  class Encrypter
    
    def initialize(text,options={})
      @public_key_file = File.join(Rails.root, 'config', 'public.pem')
      byebug
      @text       = text
    end

    def call
      public_key = OpenSSL::PKey::RSA.new(File.read(@public_key_file))
      Base64.encode64(public_key.public_encrypt(@text))
    end
    
  end
end
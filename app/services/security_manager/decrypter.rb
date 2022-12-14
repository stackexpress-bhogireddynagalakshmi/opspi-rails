require 'openssl'
require 'base64'

module SecurityManager
  class Decrypter
    
    def initialize(encypted_text, options={})
      @private_key_file = ENV['OPSPI_RSA_PRIVATE_KEY_FILE_PATH']
      @password      = ENV['OPSPI_RSA_ENC_PASSPHRASE']
      @encypted_text = encypted_text
    end

    def call
      private_key_obj = OpenSSL::PKey::RSA.new(File.read(@private_key_file),@password)
      private_key_obj.private_decrypt(Base64.decode64(@encypted_text))
    end
  end
end


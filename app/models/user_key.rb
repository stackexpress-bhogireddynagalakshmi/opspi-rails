class UserKey < ApplicationRecord
    def reseller_club_account_key_enc=(value)
     super SecurityManager::Encrypter.new(value).call
    end

    def reseller_club_account_key
      SecurityManager::Decrypter.new(reseller_club_account_key_enc).call
    end
end

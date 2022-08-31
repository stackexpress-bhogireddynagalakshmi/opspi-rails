class UserMailbox < ApplicationRecord

  def mailuser_id
    remote_mailbox_id
  end

  def autoresponder
    'n'
  end
end

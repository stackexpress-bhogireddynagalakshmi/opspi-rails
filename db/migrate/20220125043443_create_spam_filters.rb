class CreateSpamFilters < ActiveRecord::Migration[6.1]
  def change
    create_table :spam_filters do |t|
      t.integer :user_id
      t.integer :isp_config_spam_filter_id
      t.timestamps
    end
  end
end

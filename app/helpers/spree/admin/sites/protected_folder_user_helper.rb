module Spree::Admin::Sites::ProtectedFolderUserHelper
  def get_folder_path_list(web_folder_id, folders)
    return web_folder_id if folders.blank?
    begin
      folder_data = folders.select{|f| f if (f.web_folder_id == web_folder_id) }
      folder_data.first.folder
    rescue
      web_folder_id
    end
  end
end

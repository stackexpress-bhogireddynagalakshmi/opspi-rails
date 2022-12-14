// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()




// Theme
import '../theme/theme'
import '../theme/address_valid'
import '../theme/alertflash'
import '../theme/delete_address_popup'



window.infoModal = function(message, okCallback) {
  $('#infoModalTitle').html(message);
  $('#infoModal').modal('show');
  $('#btnok').html("Close");
  $('#btnok').off('click');
  $('#btnok').click(function() {
  $('#info_modal_alert_title h3').html("Alert");

    if(okCallback)
      okCallback();
  $('#infoModal').modal('hide');
  });
}


import consumer from "./consumer"

consumer.subscriptions.create("NotificationsChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("Connected");
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
    console.log("Dis Connected");
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    console.log(data)
    if( data.job_status == "completed") {
      $('#'+data.job_id+" .status").html("<i class='fa fa-check'></i> "+ data.job_status)   

      debugger

      if (data.actions == true || data.actions == "true"){
         $('#'+data.job_id+" .password a").removeClass('d-none');

      }
    }
    else {
      $('#'+data.job_id+" .status").text(data.job_status)  
    }

    show_flash("success", data.message)
    console.log("Data received"+ data);
  }
});

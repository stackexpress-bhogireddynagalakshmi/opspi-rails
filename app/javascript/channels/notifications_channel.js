import consumer from "./consumer"

consumer.subscriptions.create("NotificationsChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    debugger
    console.log("Connected");
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
    console.log("Dis Connected");
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    debugger

    show_flash("success", data.data.message)
    console.log("Data received"+ data);
  }
});

$(document).ready(function(){
    var currentLocation = window.location.pathname;
  
  if(currentLocation == '/admin/dns/hosted_zones' || currentLocation == '/admin/wizards' || currentLocation == '/admin/website_builder/site_builders' || currentLocation == '/admin/sites/isp_databases') {
    if($("#sidebarDashboards").hasClass("show")){
      $('#sidebar_dropdown').attr("aria-expanded","false");  
    } else {
      $('#sidebar_dropdown').attr("aria-expanded","true");
      $('#sidebarDashboards').addClass("show");
    }
    }
  
    if(currentLocation == '/admin/mail/domains' || currentLocation == '/admin/mail/mail_boxes' || currentLocation == '/admin/mail/mailing_lists' 
  || currentLocation == '/admin/mail/spam_filter_blacklists' || currentLocation == '/admin/mail/spam_filter_whitelists' || currentLocation == '/admin/mail/forwards'){
    if($("#sidebarSignIn").hasClass("show")){
      $('#sidebar_mail_dropdown').attr("aria-expanded","false");  
    } else {
      $('#sidebar_mail_dropdown').attr("aria-expanded","true");
      $('#sidebar_dropdown').attr("aria-expanded","true");
      $('#sidebarDashboards').addClass("show");
      $('#sidebarSignIn').addClass("show");
    }
  
  }
  
  if(currentLocation == '/admin/sites/websites' || currentLocation == '/admin/sites/sub_domains'){
    if($("#sidebarWebsites").hasClass("show")){
      $('#sidebar_websites_dropdown').attr("aria-expanded","false");  
    } else {
      $('#sidebar_dropdown').attr("aria-expanded","true");
      $('#sidebarDashboards').addClass("show");
      $('#sidebar_sites_dropdown').attr("aria-expanded","true");
      $('#sidebarSites').addClass("show");
      $('#sidebar_websites_dropdown').attr("aria-expanded","true");
      $('#sidebarWebsites').addClass("show");
    }
  }
  
  

  
    
  
  });
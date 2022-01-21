Spree.showTermsModal = function() {
    var modalSelector = '#myModal'
    
    var $modal = $(modalSelector)
     
    $.get('/terms',function(partial){
    $modal.find('#modalBody').html(partial)
    $modal.modal();
    })
}  
Spree.hideTermsModal = function() {
    var modalSelector = '#myModal'
    var $modal = $(modalSelector)
    $modal.modal('hide')
}
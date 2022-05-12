function preventNumberInput(e){
    var keyCode = (e.keyCode ? e.keyCode : e.which);
    if (keyCode >= 1 && keyCode <= 64 || keyCode >= 91 && keyCode <= 96 || keyCode > 122 ){
        e.preventDefault();
    }
}

function preventAphabetInput(e){
    var keyCode = (e.keyCode ? e.keyCode : e.which);
    if (keyCode >= 48 && keyCode <= 57){
       
    }else{
       e.preventDefault();
    }
}
$(document).ready(function(){
    $('#address_firstname').keypress(function(e) {
        preventNumberInput(e);
    });
})

$(document).ready(function(){
    $('#address_lastname').keypress(function(e) {
        preventNumberInput(e);
    });
})

$(document).ready(function(){
    $('#address_phone').keypress(function(e) {
        preventAphabetInput(e);
        max_length(e);
    });
})

$(document).ready(function(){
    $('#order_bill_address_attributes_firstname').keypress(function(e) {
        preventNumberInput(e);
    });
})

$(document).ready(function(){
    $('#order_bill_address_attributes_lastname').keypress(function(e) {
        preventNumberInput(e);
    });
})

$(document).ready(function(){
    $('#order_bill_address_attributes_phone').keypress(function(e) {
        preventAphabetInput(e);
        max_length_order(e);
    });
})


function max_length(e){
var myInput = document.getElementById("address_phone");
if(myInput.value.length >= 10){
e.preventDefault();
}

}

function max_length_order(e){
var myInput1 = document.getElementById("order_bill_address_attributes_phone");
if(myInput1.value.length >= 10){
e.preventDefault();
}
}
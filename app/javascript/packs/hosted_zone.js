
function ClearFields() {
  document.getElementById("collapseEX2").reset();
  document.getElementById("edit-form-clear-field").reset();
}

  $(document).on("click", ".cancel-button", function() {
  var collapse = $(this).closest(".collapse");
  $(collapse).collapse('toggle');
});

/////// show/hide 

$(document).ready(function(){
  showDiv('#divA')
    $('#txttype').on('change', function() {
      if ( this.value == 'A')
      {
        showDiv("#divA")
      }else if (this.value == 'AAAA')
      {
        showDiv("#divAAAA")
      }else if (this.value == 'CNAME')
      {
         showDiv("#divCNAME")

      }else if (this.value == 'MX')
      {

         showDiv("#divMX")

      }else if (this.value == 'NS')
      {
         showDiv("#divNS")
      }else if (this.value == 'TXT')
      {
        showDiv("#divTXT")
      }else{

      }
    });
});
 
function showDiv(divId){
    var divs = ["#divA","#divAAAA","#divCNAME","#divMX",'#divNS','#divTXT'];
 
    var result = divs.filter(function(elem){
      return elem != divId; 
    });

    for (var div of result) {
    $(div).hide()
    $(div).find('input:text').val('');
    $(div).find('textarea:text').val('');
    $(div).find('input').removeAttr('required')
    $(div).find('textarea').removeAttr('required')
    $(div).find('select').removeAttr('required')
    }
    $(divId).show();
    $(divId).find('input').attr('required','required')
    $(divId).find('textarea').attr('required','required')
    $(divId).find('select').attr('required','required')
}


/// search 

const searchBox = document.getElementById('searchBox');
const table = document.getElementById("myTable");
const trs = table.tBodies[0].getElementsByTagName("tr");


function performSearch() {
  var filter = searchBox.value.toUpperCase();
  for (var rowI = 0; rowI < trs.length; rowI++) {
    var tds = trs[rowI].getElementsByTagName("td");
    trs[rowI].style.display = "none";
    for (var cellI = 0; cellI < tds.length; cellI++) {
      if (tds[cellI].innerHTML.toUpperCase().indexOf(filter) > -1) {
        trs[rowI].style.display = "";
        continue;
      }
    }
  }
}

searchBox.addEventListener('keyup', performSearch);

//////////////////////////////////////////////////////////

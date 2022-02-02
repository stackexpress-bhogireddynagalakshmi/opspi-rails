
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

//////  validation add form
const form = document.getElementById('collapseEX2');
const ipv4 = document.getElementById('txtipv4');
const ipv6 = document.getElementById('txtipv6');
const target = document.getElementById('txttarget');
const mailserver = document.getElementById('txtmailserver');
const nameserver = document.getElementById('txtnameserver');
form.addEventListener('submit', e => {
    validateInputs(e);
});

const setError = (e,element, message) => {
    const inputControl = element.parentElement;
    const errorDisplay = inputControl.querySelector('.error');

    errorDisplay.innerText = message;
    inputControl.classList.add('error');
    inputControl.classList.remove('success')
    e.preventDefault();
}

const setSuccess = element => {
    const inputControl = element.parentElement;
    const errorDisplay = inputControl.querySelector('.error');

    errorDisplay.innerText = '';
    inputControl.classList.add('success');
    inputControl.classList.remove('error');
};

const isValidv4 = ipv4 => {
    const re = IPV4_REGEX;
    return re.test(ipv4);
}

const isValidv6 = ipv6 => {
    const re = IPV6_REGEX;
    return re.test(ipv6);
}

const isValidtarget = target => {
    const re = DNS_ORIGIN_ZONE_REGEX;
    return re.test(target);
}

const isValidmx = mailserver => {
    const re = DNS_ORIGIN_ZONE_REGEX;
    return re.test(mailserver);
}

const isValidns = nameserver => {
    const re = DNS_ORIGIN_ZONE_REGEX;
    return re.test(nameserver);
} 
const validateInputs = (e) => {
    const ipv4Value = ipv4.value.trim();
    const ipv6Value = ipv6.value.trim();
    const targetValue = target.value.trim();
    const mailserverValue = mailserver.value.trim();
    const nameserverValue = nameserver.value.trim();

  if (ipv4Value !== ''){
    if (!isValidv4(ipv4Value)) {
        setError(e, ipv4, 'Invalid IP Address');
    } else {
        setSuccess(ipv4);
    }
  }
  if (ipv6Value !== ''){
    if (!isValidv6(ipv6Value)) {
        setError(e, ipv6, 'Invalid IPv6 Address');
    } else {
        setSuccess(ipv6);
    }
  }
  if (targetValue !== ''){
    if (!isValidtarget(targetValue)) {
        setError(e, target, 'Invalid cname');
    } else {
        setSuccess(target);
    }
  }

  if (mailserverValue !== ''){
    if (!isValidmx(mailserverValue)) {
        setError(e, mailserver, 'Invalid mail Address');
    } else {
        setSuccess(mailserver);
    }
  }

  if (nameserverValue !== ''){
    if (!isValidns(nameserverValue)) {
        setError(e, nameserver, 'Invalid nameserver');
    } else {
        setSuccess(nameserver);
    }
  }
};

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

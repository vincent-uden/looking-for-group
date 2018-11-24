var password = document.getElementById("password");
var confirm_password = document.getElementById("confirm-password");

function validatePassword(){
    if(password.value != confirm_password.value) {
            confirm_password.setCustomValidity("Passwords Don't Match");
            console.log("kekkc");
          
    } else {
            confirm_password.setCustomValidity('');
          
    }

}

password.onchange = validatePassword;
confirm_password.onkeyup = validatePassword;

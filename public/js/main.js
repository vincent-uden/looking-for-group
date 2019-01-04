function submitLoginForm() {
    var form = document.getElementById("loginForm");
    form.submit();
}

document.addEventListener('keydown', function(event) {
    if (event.key == "Enter") {
        submitLoginForm();
    }
})

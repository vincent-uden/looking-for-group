function submitLoginForm() {
    var form = document.getElementById("loginForm");
    form.submit();
}

document.addEventListener('keydown', function(event) {
    if (event.key == "Enter") {
        submitLoginForm();
    }
})

class Request() {
    this.state = "not started";
    this.states = ["not done", "done", "failed", "waiting", "not started"];
    this.onreadyStateChange = null;

    function send() {
        this.state = "waiting";
        if (this.onreadyStateChange !== null) {
            this.onreadyStateChange();
        }

        // Something, something
        //

        this.state = "done";
        if (this.onreadyStateChange !== null) {
            this.onreadyStateChange();
        }
    }
}

let req = Request();
req.onreadyStateChange = function() {
    if (this.state == "done") {
        console.log(req.response);
    }
}

// Adding click event to dark mode toggle
var element = document.getElementById("darkModeSwitch");
var slider = document.getElementById("darkSlider");
var checkbox = document.getElementById("darkModeCheckBox");
element.addEventListener("click", function() {
    slider.classList.toggle("slidd");
    if (checkbox.checked) {
        checkbox.checked = false;
    } else {
        checkbox.checked = true;
    }
    submitDarkMode();
})

window.onload = function() {
    var main = document.getElementsByClassName("preload")[0];
    main.classList.remove("preload");
}

function submitDarkMode() {
    var form = document.getElementById("darkModeForm");
    //form.submit();
    
    var request = new XMLHttpRequest();
    var url = "/account/manage/dark_mode/";
    url += checkbox.checked;

    request.onreadystatechange = function () {
        console.log(request.status);
        if (request.readyState === 4 && request.status === 200) {
            let body = document.getElementsByTagName("body")[0];
            body.classList.toggle("light");
            body.classList.toggle("dark");
        }
    }

    console.log(url);
    request.open("POST", url);
    request.send();
}

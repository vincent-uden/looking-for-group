// Adding click event to dark mode toggle
var element = document.querySelector("#darkModeSwitch");
var slider = document.querySelector("#darkSlider");
var checkbox = document.querySelector("#darkModeCheckBox");
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
    var main = document.querySelector(".preload");
    main.classList.remove("preload");
}

function submitDarkMode() {
    var form = document.querySelector("#darkModeForm");
    form.submit();
}


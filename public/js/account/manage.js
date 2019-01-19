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
    var url = "/account/manage/darkMode/";
    url += checkbox.checked; //TODO: Finish
    console.log(url);
}

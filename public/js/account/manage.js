var element = document.querySelector("#darkModeSwitch");
console.log("Test");
console.log(element);
element.addEventListener("click", function() {
    var slider = document.querySelector("#darkSlider");
    slider.classList.toggle("slidd");
})

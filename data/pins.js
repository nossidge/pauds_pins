
// Random number between two values.
function rand(_max, _min, _int) {
  let max = (_max === 0 || _max) ? _max : 1,
      min = _min || 0,
      gen = min + (max - min) * Math.random();
  return (_int) ? Math.round(gen) : gen;
}

// Random element from an array.
function arrayRand(array) {
  return array[rand(0, array.length - 1, true)];
}

////////////////////////////////////////////////////////////////////////////////

// Stuff for showing and hiding the bottom div.
let detailHidden = true;
let iconUp   = "&#x25B2;";
let iconDown = "&#x25BC;";

// Show/hide the detail popup.
function detailToggle() {
  let popup = document.getElementById("popup");
  let arrow = document.getElementById("arrow");
  if (detailHidden) {
    detailShow(popup, arrow);
  } else {
    detailHide(popup, arrow);
  }
  detailHidden = !detailHidden;
}

// When it is hidden and we want to show it.
function detailShow(popup, arrow) {
  popup.className = "visible";
  popup.style.bottom = "0px";
  arrow.innerHTML = iconDown;
}

// When it is visible and we want to hide it.
function detailHide(popup, arrow) {
  popup.className = "hidden";
  popup.style.bottom = "-110px";
  arrow.innerHTML = iconUp;
}

////////////////////////////////////////////////////////////////////////////////

// Get the current value of the 'click' radios.
function radioValue() {
  let query = "input[name='click']:checked";
  return document.querySelector(query).value;
}

// Select the correct radio button when its label is clicked.
function selectRadio(self) {
  let value = self.getAttribute("for");
  let query = "input[value='" + value + "']";
  let radio = document.querySelector(query);
  radio.checked = true;
}

////////////////////////////////////////////////////////////////////////////////

// Define global vars.
let imagesDiv, pinsJSON;

// All backgrounds are in this album: imgur.com/a/7lZobWg
function setBackground() {
  let imgsBackgroundArray = ["f8NuXl3", "M4rQpWK", "oSFBiMW"];
  let img = arrayRand(imgsBackgroundArray);
      img = "https://i.imgur.com/" + img + ".png";
  let bgImage = "background-image: url('" + img + "');";
  let bgSize  = "background-size: cover;";
  document.body.style = bgImage + bgSize;
}

// Add a new image somewhere on the page.
function addImage() {
  let img = arrayRand(pinsJSON);
  let topY   = rand(-10, 90, true);
  let leftX  = rand(-15, 95, true);
  let rotate = rand(-40, 40, true);

  let position = "position:absolute;";
  let width = "width:auto;";
  let top = "top:" + topY + "%;";
  let left = "left:" + leftX + "%;";
  let transform = "transform:rotate(" + rotate + "deg);";
  let maxHeight = "max-height:320px;";
  let style = " style='" +
    position + width + top + left + transform + maxHeight
  + "'";

  let title   = " title='" + img["title"] + "'";
  let page     = " page='" + img["page"] + "'";
  let src     = " src='" + img["png_x320"] + "'";
  let onclick = " onclick='pinOnclick(this)'";

  let wholeThing = "<img" + title + page + src + onclick + style + ">";
  imagesDiv.innerHTML += wholeThing;
}

// Delete an element from the DOM.
function killImage(self) {
  self.outerHTML = "";
}

// Kill the image and draw a new one.
function respawn(self) {
  killImage(self);
  addImage();
}

// Kill any image and draw a new one.
function respawnRandom() {
  let imgs = document.getElementsByTagName("img");
  let img = arrayRand(imgs);
  respawn(img);
}

// Clear existing images and redraw.
function resetImages() {
  let count = 60;
  imagesDiv.innerHTML = "";
  for(let i = 0; i < count; i++) {
    addImage();
  }
}

// Initialise the images.
function initPage() {
  imagesDiv = document.getElementById("images");
  setBackground();
  resetImages();

  let query = "input[name='click'][value='random']";
  let radio = document.querySelector(query);
  radio.checked = true;
}

////////////////////////////////////////////////////////////////////////////////

// Wait for the JSON to be loaded.
document.addEventListener("DOMContentLoaded", function(e) {
  let x = new XMLHttpRequest();
  x.open("GET", "pins.json", true);
  x.responseType = "json";
  x.onload = function() {
    pinsJSON = x.response;
    initPage();
  }
  x.send(null);
});

// Disable default space scroll down behaviour.
window.onkeydown = function(e) {
  return !(e.keyCode == 32);
};

// Respawn on spacebar press, redraw images on R press.
window.addEventListener("keydown", keydownEvents, false);
function keydownEvents(e) {
  if (e.keyCode == 32) {
    respawnRandom();
  } else if (e.keyCode == 82) {
    resetImages();
  }
}

// Handle image onclick event.
function pinOnclick(self) {
  if (radioValue() == "link") {
    let page = self.getAttribute("page");
    window.open(page, "_blank");
  } else {
    respawn(self);
  }
}

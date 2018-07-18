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
  arrow.setAttribute("class", "spin");
}

// When it is visible and we want to hide it.
function detailHide(popup, arrow) {
  popup.className = "hidden";
  popup.style.bottom = "-110px";
  arrow.setAttribute("class", "spun");
}

////////////////////////////////////////////////////////////////////////////////

// Get the current value of the 'click' radios.
function radioValue() {
  let query = "input[name='click']:checked";
  return document.querySelector(query).value;
}

// Select the correct radio button when its label is clicked.
function selectRadio(value) {
  let query = "input[value='" + value + "']";
  let radio = document.querySelector(query);
  radio.checked = true;
  toggleAnchorHrefs(value == 'link');
}

// Toggle the hrefs on or off.
function toggleAnchorHrefs(on) {
  let pins = document.getElementsByClassName("pin");
  for(let i = 0; i < pins.length; i++) {
    let pin = pins[i];
    let anchor = pin.getElementsByTagName("a")[0];
    let img = anchor.getElementsByTagName("img")[0];
    if (on) {
      let page = img.getAttribute("page");
      anchor.setAttribute("href", page);
    } else {
      anchor.removeAttribute("href");
    }
  }
}

////////////////////////////////////////////////////////////////////////////////

// Define global vars.
let imagesDiv, pinsJSON;

// All backgrounds are in this album: imgur.com/a/7lZobWg
function setBackground() {
  let imgsBackgroundArray = ["f8NuXl3", "M4rQpWK", "oSFBiMW"];
  let bg = arrayRand(imgsBackgroundArray);
      bg = "https://i.imgur.com/" + bg + ".png";
  let bgImage = "background-image: url('" + bg + "');";
  let bgSize  = "background-size: cover;";
  document.body.style = bgImage + bgSize;
}

// Add a new image somewhere on the page.
function addImage(id) {

  // Set CSS style and position.
  let topY   = rand(-10, 90, true);
  let leftX  = rand(-15, 95, true);
  let rotate = rand(-40, 40, true);
  let position = "position:absolute;";
  let width = "width:auto;";
  let top = "top:" + topY + "%;";
  let left = "left:" + leftX + "%;";
  let transform = "transform:rotate(" + rotate + "deg);";
  let maxHeight = "max-height:320px;";
  let style = position + width + top + left + transform + maxHeight;

  // Re-use the existing element, or create new if null.
  let div = document.getElementById(id);
  if (div == null) div = document.createElement("div");
  let img = getOrCreate(div, "img");
  let anchor = getOrCreate(img, "a");

  div.setAttribute("id", id);
  div.setAttribute("class", "pin");
  div.setAttribute("style", style);
  div.setAttribute("onclick", "pinOnclick(this)");

  let imgObj = arrayRand(pinsJSON);
  img.setAttribute("title", imgObj["title"]);
  img.setAttribute("page", imgObj["page"]);
  img.setAttribute("src", imgObj["png_x320"]);

  anchor.setAttribute("target", "_blank");
  anchor.setAttribute("rel", "noopener noreferrer");
  if (radioValue() == "link") anchor.setAttribute("href", imgObj["page"]);

  div.appendChild(anchor);
  anchor.appendChild(img);

  document.getElementById("images").appendChild(div);
}

// Re-use the existing element, or create new if null.
function getOrCreate(parent, tagName) {
  let element = parent.getElementsByTagName(tagName);
  if (element.length == 0) {
    element = document.createElement(tagName);
  } else {
    element = element[0];
  }
  return element;
}

// Delete an element from the DOM.
function killImage(self) {
  self.outerHTML = "";
}

// Kill the image and draw a new one.
function respawn(self) {
  killImage(self);
  addImage(self.id);
}

// Kill any image and draw a new one.
function respawnRandom() {
  let pins = document.getElementsByClassName("pin");
  let pin = arrayRand(pins);
  respawn(pin);
}

// Clear existing images and redraw.
function resetImages() {
  let count = 60;
  imagesDiv.innerHTML = "";
  for(let i = 0; i < count; i++) {
    let id = "pin" + i;
    addImage(id);
  }
}

// Initialise the images.
function initPage() {
  imagesDiv = document.getElementById("images");
  let query = "input[name='click'][value='random']";
  let radio = document.querySelector(query);
  radio.checked = true;
  setBackground();
  resetImages();
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
  if (radioValue() == "random") respawn(self);
}

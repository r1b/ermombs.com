// Fear & Loathing In Brooklyn
// r1b 2019

// References
// https://css-tricks.com/random-numbers-css/
// https://splitting.js.org/

// Procedure
// 1. Every t ms
//      i. Pick n indices between 0 - m where `m` is the number of characters
//      ii. For each index
//          a. Apply a class to the character at m that dilates the character
//             over u ms where u < 10000ms
//          b. Apply a listener that removes the class on animation end.

// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/random
function getRandomInt(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

const INTERVAL_MS = 4200;
const MAX_ANIMATION_TIME_MS = 10000;
const text = Splitting()[0];

setInterval(function () {
  const numCharacters = getRandomInt(text.chars.length);
  for (let i = 0; i < numCharacters; i++) {
    const element = text.chars[getRandomInt(text.chars.length)];
    element.style.setProperty("--animation-time", getRandomInt(MAX_ANIMATION_TIME_MS))
    element.classList.add("dilate");
    element.addEventListener("animationend", function () {
      element.classList.remove("dilate");
      element.style.removeProperty("--animation-time");
    });
  }
}, INTERVAL_MS);

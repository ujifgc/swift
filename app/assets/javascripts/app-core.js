//= require ./libraries/01-jquery-1.8.2.js
//= require ./libraries/07-jquery.colorbox-min.js

$(function() {
  var boxOptions = { opacity: 0.7, loop: false, current: "{current} / {total}", previous: "<", next: ">", close: "x", maxWidth: "100%", maxHeight: "100%" };
  if ($.browser.msie && $.browser.version < '8.0.0')
    boxOptions.transition = "none";
  $('[rel^="box-"]').colorbox(boxOptions);
});
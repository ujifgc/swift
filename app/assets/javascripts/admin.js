//= require jquery
//= require jquery-ujs
//= require jquery-ui
//= require jquery.colorbox-min
//= require paginator3000
//= require postmessage
//= require editor

$(function() {
  var boxOptions = { opacity: 0.7, loop: false, current: "{current} / {total}", previous: "<", next: ">", close: "x", maxWidth: "100%", maxHeight: "100%" };
  if ($.browser.msie && $.browser.version < '8.0.0')
    boxOptions.transition = "none";
  $('[rel^="box-"]').colorbox(boxOptions);
});

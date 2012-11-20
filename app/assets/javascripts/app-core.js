//= require ./libraries/01-jquery-1.8.2.js
//= require ./libraries/07-jquery.colorbox-min.js

$(function() {
  var boxOptions = { opacity: 0.7, loop: false, current: "{current} / {total}", previous: "<", next: ">", close: "x", maxWidth: "100%", maxHeight: "100%" };
  if ($.browser.msie && $.browser.version < '8.0.0')
    boxOptions.transition = "none";
  $('[rel^="box-"]').colorbox(boxOptions);
});
$(document).bind('cbox_load', function(){
  $('#cboxTextOverlay').remove();
});
$(document).bind('cbox_complete', function(){
  var el = $.colorbox.element();
  var text = '<small>' + el.prop('title') + '</small>';
  $('#cboxContent').append("<div id='cboxTextOverlay'>"+text+"</div>");
  $('#cboxTitle').remove();
  $('#cboxContent').hover(function() {
    $('#cboxTextOverlay').fadeIn('fast');
  }, function() {
    $('#cboxTextOverlay').fadeOut('fast');
  });
});
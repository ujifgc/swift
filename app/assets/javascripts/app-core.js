//= require ./libraries/01-jquery-1.8.2.js
//= require ./libraries/07-jquery.colorbox-min.js

$(function() {
  window.boxOptions = { opacity: 0.85, loop: false, current: "{current} / {total}", previous: "←", next: "→", close: "Esc", maxWidth: "80%", maxHeight: "100%", transition: "elastic" };
  if ($.browser.msie && $.browser.version < '8.0.0')
    window.boxOptions.transition = "none";
  $('[rel^="box-"]').colorbox(window.boxOptions);
});
$(document).bind('cbox_load', function(){
  $('#cboxTextOverlay').remove();
});
$(document).bind('cbox_closed', function(){
  $(document.body).css('overflow-y', 'auto');
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
  $('#cboxOverlay').append('<div id="cboxControls"></div>');
  $('#cboxClose, #cboxCurrent, #cboxPrevious, #cboxNext').appendTo('#cboxControls');
  $('#cboxClose, #cboxCurrent, #cboxPrevious, #cboxNext').click(function(e) {
    e.stopPropagation();
  });
  $(document.body).css('overflow-y', 'scroll');
});

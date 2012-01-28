//= require Markdown.Converter
//= require Markdown.Editor
//= require Markdown.Sanitizer
//= require easyselectbox

bindMarkdowns = function() {
  $('textarea.markdown').each( function() {
    var id = this.id, old = false;
    if (id.match(/wmd-input/)) {
      id = id.replace('wmd-input-', '');
      old = true;
    }else{
      this.id = 'wmd-input-'+id;
    }
    $(this).addClass('wmd-input');
    if (!old) $(this).before('<div id="wmd-button-bar-'+id+'"></div>');
    this.wconverter = Markdown.getSanitizingConverter();
    this.weditor = new Markdown.Editor(this.wconverter, '-'+id);
    this.weditor.run();
  });
};

$(function() {
  bindMarkdowns();
});


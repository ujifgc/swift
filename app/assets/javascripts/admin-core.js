$(function() {
  var boxOptions = { opacity: 0.7, loop: false, current: "{current} / {total}", previous: "<", next: ">", close: "x", maxWidth: "100%", maxHeight: "100%" };
  if ($.browser.msie && $.browser.version < '8.0.0')
    boxOptions.transition = "none";
  $('[rel^="box-"]').colorbox(boxOptions);
  $(':checkbox[name=check_all]').click(function(){
    $(':checkbox[name^=check_]').prop('checked', $(this).prop('checked'));
  });
  $('a.multiple').click(function(){
    multipleOp(this);
  });
  $('a.single.button_to').click(function(){
    singleOp(this);
  });
  multipleCheck();
  $('form.multiple input[name^=check]').click(multipleCheck);
  $('form.multiple th.last input').wrap('<label></label>');
  $('select').each(function() { $(this).easySelectBox() });
  $('input.datetime').each(function() {
    $(this).datetimepicker( { dateFormat: 'yy-mm-dd', timeFormat: 'hh:mm' } );
  });
  $('a.dialog').click(function() {
    var url = this.href;
    var title = this.title ? this.title : '';
    var dialog = $('<div id="modal-dialog" title="'+title+'"style="display:none" class="loading"></div>').appendTo('body');
    this.dialog = dialog;
    dialog.dialog({
      close: function(event, ui) {
        dialog.remove();
      },
      width: 800,
      minHeight: 600,
      modal: true
    });
    dialog.load(
      url,
      function (responseText, textStatus, XMLHttpRequest) {
        dialog.removeClass('loading');
      }
    );
    return false;
  });
});

multipleOp = function(el) {
  if (el.disabled) return false;
  el.disabled = true;
  var models = $('form.multiple')[0].id.split('-')[1]
  var action = '/admin/'+models+'/multiple?_method='+$(el).attr('data-method');
  $('form.multiple').attr( { action: action } ).submit();
  toggleCheck(el, -1);
  return false;
};

toggleCheck = function(el, check) {
  $('form.multiple input[name^=check_]').prop('checked', check ? (check > 0 ? true : false) : el.checked);
  multipleCheck(el);
};

multipleCheck = function(el) {
  $('#operations a.multiple').parent().addClass('blurry');
  $('form.multiple input[name^=check]').each(function() {
    if (this.checked) return $('#operations a.multiple').parent().removeClass('blurry');
  });
};

$.fn.toggleCheckbox = function() {
  this.prop('checked', !this.prop('checked'));
  return $(this);
}

//Bondables
bindDialogBonds = function() {
  $('#tabs-bondables').tabs({ cache: true });
  $('#tabs-bondables').bind( "tabsload", function(event, ui) {
    var links = $(ui.panel).find('a.pick');
    links.each(function() {
      var checked = $(this).data('bound').toString() == 'true' ? 'checked=checked' : '';
      name = 'bond['+$(this).data('model')+']['+$(this).data('id')+']';
      $(this).after('<input type=checkbox '+checked+' name='+name+' />');
    });
    links.click(function(event) {
      $(this).siblings(':checkbox').toggleCheckbox().change();
    });
    links.siblings(':checkbox').change(function(event) {
      var checked = $(this).prop('checked');
      var link = $(this).siblings('a.pick')
      data = link.data();
      var selector = 'a.pick[data-model='+data.model+'][data-id='+data.id+']';
      $('.active-bonds '+selector).parent().remove();
      if (checked) {
        var newlink = link.clone(); //.find('.image').remove().end()
        newlink.html(link.text() + '(' + data.model + ')');
        $('.active-bonds').append('<div class=item><a class=unbind href="javascript:;" onclick="bond_uncheck()"><img src="/images/icons/cancel_16.png"/></a></div>').find('div').last().prepend(newlink);
      }
    });
  });
  $('#tabs-bondables').bind( "tabsselect", function(event, ui) {
    if ($(ui.tab).data('model') != 'Bond') return true;
  });

  $('a.save-dialog').click(function() {
    var alldata = {};
    $('.active-bonds a.pick').each(function() {
      var data = $(this).data();
      alldata['bond['+data.model+']['+data.id+']'] = 'on';
    });
    $.ajax({
      type: 'POST',
      url: $('.dialog-bonds form').prop('action'),
      data: alldata,
      success: function(jqXHR, textStatus, errorThrown) {
        if (typeof jqXHR == 'string') {
          alert(jqXHR);
        }else{
          $('#modal-dialog').dialog('close');
        }
      },
      error: function(jqXHR, textStatus, errorThrown) {
        alert(textStatus);
      }
    });
  });
  $('a.cancel-dialog').click(function() {
    $('#modal-dialog').dialog('close');
  });
}

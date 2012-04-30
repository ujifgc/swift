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

  // datatables

/* Table initialisation */
  var cols = [ { "sType": "by-data" } ];
  for ( var i = $('.multiple table.table tbody tr').first().children().length; i > 1; i--) cols.push(null);
  $('.multiple table.smart').dataTable( {
    "sDom": "<'page-filter'rf>t<'page-control'<'inline pick-page'p><'hide length'l>>",
    "sPaginationType": "bootstrap",
    "bStateSave": true,
	"oLanguage": {
      "sLengthMenu": "_MENU_",
      "sSearch": "Фильтр: ",
      "oPaginate": {
        "sNext": "",
        "sPrevious": ""
      }
	},
	"aoColumns": cols,
	"aLengthMenu": [[15, -1], [15, "Все"]],
	"iDisplayLength": 15
  } );
  $('.dataTables_length').parent().after('<div class="inline pick-length"><ul class="nav nav-pills"><li class="nav-header">Объектов на странице:</li><li><a href="javascript:;" onclick="pickLength(this)" data-length="15">15</a></li><li><a href="javascript:;" onclick="pickLength(this)" data-length="-1">Все</a></li></ul></div>');
  $('.dataTables_filter input[type=text]').addClass('search-query');
  var len = $('table.table').dataTableSettings[0]._iDisplayLength;
  if (len == -1) $('.inline .pagination').hide(); else $('.inline .pagination').show();
  $('.pick-length a[data-length='+len+']').parent().addClass('active');

  $('a.single.button_to').click(function(){
    singleOp(this);
  });
  multipleCheck();
  $('form.multiple input[name^=check]').click(multipleCheck);
  $('select').each(function() { $(this).easySelectBox() });
  bindCatCards();
  $('input.datetime').each(function() {
    //$(this).datetimepicker( { dateFormat: 'yy-mm-dd', timeFormat: 'hh:mm' } );
  });
  $('a[data-toggle=modal]').click(function() {
    var url = this.href;
    var dialog = $('<div id="modal-dialog" class="modal hide loading"></div>').appendTo('body');
    this.dialog = dialog;
    dialog.load(
      url,
      function (responseText, textStatus, XMLHttpRequest) {
        dialog.removeClass('loading');
      }
    );
    dialog.modal('show');
    dialog.on('hidden', function () {
      dialog.remove();
    });
    return false;
  });
  $('textarea.resizable').TextAreaResizer();
});

pickLength = function(e) {
  var len = $(e).data('length');
  if (len == -1) $('.inline .pagination').hide(); else $('.inline .pagination').show();
  $('.dataTables_length select').val(len).change();
  $('.pick-length li').removeClass('active');
  $(e).parent().addClass('active');
};

multipleOp = function(el) {
  if (el.disabled) return false;
  el.disabled = true;
  var models = $('form.multiple')[0].id.split('-')[1];
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
};

//Catalogue
bindCatCards = function(elem) {
  (elem || $('form#edit-cat_cards .as_group select')).change(function() {
    if (this.value.match(/select|multiple/))
      $(this).siblings('textarea').removeClass('hide');
    else
      $(this).siblings('textarea').addClass('hide');
  });
};

cloneControlGroup = function(el) {
  var g = $(el).parent().siblings('.controls.hide');
  var c = g.clone();
  var add = '-'+(new Date()).getTime();
  c.children('input, select, textarea').each(function(){ this.name = this.name.replace(/\[(.*)\]/, '[$1'+add+']') });
  c.removeClass('hide').find('.easy-select-box').remove();
  sel = c.find('select');
  sel.easySelectBox();
  bindCatCards(sel);
  g.before(c);
};

addCheckboxes = function(selector) {
  var links = $(selector).find('a.pick');
  links.each(function() {
    var checked = $(this).data('bound').toString() === 'true' ? 'checked=checked' : '';
    var name = 'bond['+$(this).data('model')+']['+$(this).data('id')+']';
    $(this).after('<input type=checkbox '+checked+' name='+name+' />');
  });
  links.click(function(event) {
    $(this).siblings(':checkbox').toggleCheckbox().change();
  });
  links.siblings(':checkbox').change(function(event) {
    var checked = $(this).prop('checked');
    var link = $(this).siblings('a.pick');
    var data = link.data();
    var selector = 'a.pick[data-model='+data.model+'][data-id='+data.id+']';
    $('.active-bonds '+selector).parent().remove();
    if (checked) {
      var newlink = link.clone();
      newlink.html(link.text() + '(' + data.model + ')');
      $('.active-bonds').append('<div class=item><a class=unbind href="javascript:;" onclick="bond_uncheck()"><img src="/images/icons/cancel_16.png"/></a></div>').find('div').last().prepend(newlink);
    }
  });
}

bindTabs = function(selector) {
  $(selector).tab();
  $(selector).find('li.tab.active a').data('cached', 1);
  var url = $(selector).find('li.tab.active a').data('url');
  var pane = $(selector).next().find('.tab-pane.active');
  pane.load(url, function() {
    addCheckboxes(pane);
  });
  $(selector).on('show', function(e) {
    if ($(e.target).data('cached')) return;
    var url = $(e.target).data('url');
    var pane = $($(e.target).attr('href'));
    pane.load(url, function() {
      $(e.target).data('cached', 1);
      addCheckboxes(pane);
    });
  });
};

//Bondables
bindDialogBonds = function() {
  bindTabs('#tabs-bondables');

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
        if (typeof jqXHR === 'string') {
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
};

//Create parent
bindDialogCreateParent = function() {
  var form = $('#modal-dialog').find('form');
  $('a.save-dialog').click(function() {
    $.ajax({
      type: 'POST',
      url: form.prop('action'),
      data: form.serialize(),
      success: function(jqXHR, textStatus, errorThrown) {
        if (typeof jqXHR === 'string') {
          alert(jqXHR);
        }else{
          $('select[id$='+jqXHR.field+']')
            .append('<option value="'+jqXHR.key+'">'+jqXHR.value+'</option>')
            .val(jqXHR.key)
            .siblings('.easy-select-box').remove();
          $('select[id$='+jqXHR.field+']').easySelectBox();
        }
      },
      error: function(jqXHR, textStatus, errorThrown) {
        alert(textStatus);
      }
    });
  });
};

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

/* pages */
  $('[data-reposition]').closest('.btn').on('click', function() {
    if (this.disabled) return false;
    this.disabled = true;
    var models = $('form.multiple')[0].id.split('-')[1];
    var id = $(this).closest('tr')[0].id.split('-')[1];
    var action = '/admin/'+models+'/reposition/'+id+'/'+$(this).find('[data-reposition]').data('reposition');
    $('form.multiple').attr( { action: action } ).submit();
  });

/* sidebar */
  $('h5.nav-header[data-toggle]').popover({ trigger: 'manual', placement: 'right-down', animation: 'show' });
  $('h5.nav-header[data-toggle]').mouseenter(function() {
    if ($(this).hasClass('collapsed'))
      $(this).popover('show');
  });
  $('h5.nav-header[data-toggle]').mouseleave(function() {
    $(this).popover('hide')
  });
  $('h5.nav-header[data-toggle]').on('click', function() {
    var target = $($(this).data('toggle'));
    if (target.find('li.active').length > 0) {
      hei = target.height();
      target.animate( { height: '0px' }, 500 );
      setTimeout(function() {
        target.stop().animate( { height: hei + 'px' }, 125, function() {
          target.css( { height: 'auto', overflow: 'visible' } );
        });
      }, 125);
      return;
    }
    target.slideToggle();
    $(this).toggleClass('collapsed');
    var id = $(this).data('toggle').split('-').pop();
    var coo = ($.cookie('sbc')||'').replace(id+' ', '');
    if ($(this).hasClass('collapsed'))
      coo += id + ' ';
    else
      $(this).popover('hide')
    $.cookie('sbc', coo, { path: '/admin/' });
  });

  // datatables

/* Table initialisation */
  var cols = [ { "sType": "by-data" } ];
  for ( var i = $('.multiple table.table tbody tr').first().children().length; i > 1; i--) cols.push(null);
  var lenHash = [[15, 25, -1], [15, 25, "Все"]];
  $('.multiple table.smart').addClass('table-condensed').dataTable( {
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
	"aLengthMenu": lenHash,
	"iDisplayLength": -1
  } );
  if ($('table.table').length > 0 && $('table.table').dataTableSettings[0]) {
    var lengthes = '';
    for (var ii in lenHash[0]) {
      lengthes += '<li><a href="javascript:;" onclick="pickLength(this)" data-length="'+lenHash[0][ii]+'">'+lenHash[1][ii]+'</a></li>';
    }
    $('.dataTables_length').parent().after('<div class="inline pick-length"><ul class="nav nav-pills"><li class="nav-header">Объектов на странице:</li>'+lengthes+'</ul></div>');
    $('.dataTables_filter input[type=text]').addClass('search-query');

    var len = $('table.table').dataTableSettings[0]._iDisplayLength;
    if (len == -1) $('.inline .pagination').hide(); else $('.inline .pagination').show();
    $('.pick-length a[data-length='+len+']').parent().addClass('active');
  }

  $('a.single.button_to').click(function(){
    singleOp(this);
  });
  multipleCheck();
  $('form.multiple input[name^=check]').click(multipleCheck);
  bindCatCards();
  $('input.datetime').each(function() {
    $(this).wrap('<div class="input-prepend date"></div>');
    $(this).before('<span class="add-on"><i class="icon-calendar"></i></span>');
    $(this).siblings('.add-on').click(function() { $(this).siblings('input')[0].focus() });
    $(this).datepicker( { format: 'yyyy-mm-dd', weekStart: 1, language: 'ru', autoclose: true, formatTime: 'hh:mm' } );
  });
  $('a[data-toggle=modal]').click(function() {
    var url = this.href;
    $('body > .modal').remove();
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
  (elem || $('form .as_clonable select')).on('change', function() {
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
  c.removeClass('hide');
  sel = c.find('select');
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

bindTabs = function(selector, op) {
  if (!op) op = 'select';
  $(selector).tab();
  $(selector).find('li.tab.active a').data('cached', 1);
  var url = $(selector).find('li.tab.active a').data('url');
  var pane = $(selector).next().find('.tab-pane.active');
  pane.load(url, function() {
    pane.trigger('pane-loaded');
    if (op == 'select')
      addCheckboxes(pane);
  });
  $(selector).on('show', function(e) {
    if ($(e.target).data('cached')) return;
    var url = $(e.target).data('url');
    var pane = $($(e.target).attr('href'));
    pane.load(url, function() {
      $(e.target).data('cached', 1);
      pane.trigger('pane-loaded');
      if (op == 'select')
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
          $('#modal-dialog').modal('hide');
        }
      },
      error: function(jqXHR, textStatus, errorThrown) {
        alert(textStatus);
      }
    });
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
            .val(jqXHR.key);
        }
      },
      error: function(jqXHR, textStatus, errorThrown) {
        alert(textStatus);
      }
    });
  });
};

bindBlockType = function() {
  $.fn.editable.defaults.placeholder = '&nbsp;';
  var select = $('select[id$=block_type]');
  var area = $('textarea[id$=block_text]');
  var controls = area.closest('.controls');
  controls.after('<div class="table controls">' + 
    '<div class="inline vtop wrapper"></div><div class="btn-group inline">' +
      '<a onclick="chTable(this)" class="btn btn-mini"><i class="icon-plus"></i></a>' +
      '<a onclick="chTable(this)" class="btn btn-mini"><i class="icon-minus"></i></a>' +
      '<a onclick="chTable(this)" class="btn btn-mini"><i class="icon-bold"></i></a>' +
    '</div><div class="btn-group block">' +
      '<a onclick="chTable(this)" class="btn btn-mini"><i class="icon-plus"></i></a>' +
      '<a onclick="chTable(this)" class="btn btn-mini"><i class="icon-minus"></i></a>' +
      '<a onclick="chTable(this)" class="btn btn-mini"><i class="icon-bold"></i></a>' +
    '</div></div>');
  var table = controls.siblings('div.table').find('.wrapper');
  var table_controls = table.parent();
  table_controls.siblings('label').append('<div class="insert"><a class="btn btn-mini" onclick="insertTable(this)"><i class="icon-share"></i> Вставить</a>');
  var insert = table_controls.siblings('label').find('.insert');

  insertTable = function(e) {
    var dialog = $('<div id="modal-dialog" class="modal hide">' + 
      '<div class="modal-header"><a data-dismiss="modal" class="close">×</a><h3>Вставка таблицы</h3>Вставьте в поле ввода таблицу из табличного редактора или текстового процессора с помощью клавиш <b>Ctrl-V</b> или <b>Shift-Insert</b>, затем нажмите кнопку «Вставить».<br><b>Внимание!</b> Содержимое блока будет заменено новыми данными.</div>' +
      '<div class="modal-body"><textarea id="spreadsheet-data"></textarea></div>' +
      '<div class="modal-footer"><a href="javascript:;" data-dismiss="modal" class="btn btn-primary save-dialog">Вставить</a><a href="javascript:;" data-dismiss="modal" class="btn cancel-dialog">Отмена</a></div>' +
    '</div>').appendTo('body');
    dialog.find('a.save-dialog').click(function() {
      var clipRows = $('textarea#spreadsheet-data').val().split(/[\r\n]+/);
      for (i=0; i < clipRows.length; i++) {
        clipRows[i] = clipRows[i].split(/\t/);
      }
      var newTable = '<table class="table table-bordered">';
      for (i=0; i < clipRows.length; i++) {
        var cells = '';
        for (j=0; j<clipRows[i].length; j++) {
          cells += '<td>' + clipRows[i][j] + "</td>";
        }
        newTable += '<tr>' + cells + '</tr>';
      }
      newTable += '</table>';
      if (newTable.length > 15) table.html(newTable);
      edifyTable();
      dialog.modal('hide');
    });
    e.dialog = dialog;
    dialog.modal('show');
    dialog.on('hidden', function () {
      dialog.remove();
    });
    return false;
  };

  chTable = function(e) {
    var op = $(e).find('i')[0].className;
    var tg = $(e).parent()[0].className;
    var the_table = table.find('table');
    if (tg.match(/inline/)) {
      if (op == 'icon-plus') {
        the_table.find('tr').append('<td></td>');
      }else if (op == 'icon-minus') {
        if (the_table.find('tr td').length > 1)
          the_table.find('tr td:last-child').remove();
      }else if (op == 'icon-bold') {
        var tds = the_table.find('tr').first().html();
        if (tds.match(/\<td(.*?)\>/))
          tds = tds.replace(/\<td(.*?)\>/g, "<th$1>");
        else
          tds = tds.replace(/\<th(.*?)\>/g, "<td$1>");
        the_table.find('tr').first().html(tds);
      }
      edifyTable();
    }else if (tg.match(/block/)) {
      if (op == 'icon-plus') {
        var row = '<tr>';
        for (var i = the_table.find('tr:last-child td').length; i > 0; i--) {
          row += '<td></td>';
        }
        row += '</tr>';
        the_table.append(row);
      }else if (op == 'icon-minus') {
        if (the_table.find('tr').length > 1)
          the_table.find('tr:last-child').remove();
      }else if (op == 'icon-bold') {
        the_table.find('tr').each(function() {
          var tds = $(this).html();
          if (tds.match(/\<th(.*?)\>/))
            tds = tds.replace(/\<th(.*?)\>/, "<td$1>");
          else
            tds = tds.replace(/\<td(.*?)\>/, "<th$1>");
          $(this).html(tds);
        });
      }
      edifyTable();
    }
  };

  edifyTable = function() {
    var clone = table.clone();
    clone.find('table').removeClass('table table-bordered');
    area.val(clone.html().replace(" class=\"\"", ''));
    table.find('table td, table.th').click(function() {
      $('.btn-primary').attr('disabled','disabled');
    }).editable(function(value, settings) {
      return value;
    }, {
      onblur: "submit",
      callback: function(value, settings) {
        $('.btn-primary').removeAttr('disabled');
        var clone = table.clone();
        clone.find('table').removeClass('table table-bordered');
        area.val(clone.html().replace(" class=\"\"", ''));
      }
    });
  };

  //if (!area.val().match(/$\<table.*table\>^/) && area.val().length > 0 )
  //  select.parents('.control-group').remove();
  select.change(function() {
    var html = area.val();
    var wmdpanel = controls.find('[id^=wmd-button-bar]');
    switch (select.find('option[selected]').val()) {
    case "0":
      controls.show();
      wmdpanel.show();
      table_controls.hide();
      insert.hide();
      break;
    case "1":
      controls.show();
      wmdpanel.hide();
      table_controls.hide();
      insert.hide();
      break;
    case "2":
      controls.hide();
      table_controls.show();
      insert.show();
      table.html(html.indexOf('table') == -1 ? '<table class="table table-bordered"><tr><td>Новая таблица</table>' : html);
      table.find('table').addClass('table table-bordered');
      edifyTable();
      break;
    }
  });
  $(function() {
    select.change();
  });
};

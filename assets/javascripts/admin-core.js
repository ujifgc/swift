$(function() {
  $(document).bind('drop dragover', function (e) {
    e.preventDefault();
  });
  $(':checkbox[name=check_all]').click(function(){
    $(':checkbox[name^=check_]').prop('checked', $(this).prop('checked'));
  });
  $('a.multiple').click(function(){
    multipleOp(this);
  });
  $(document).keypress(function(event) {
    if (event.ctrlKey && event.charCode == 115) {
      $(".form-actions .btn-primary").click();
      return false;
    }
    
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
  $('[rel=tooltip]').tooltip({ animation: false });
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
  bindDatetime();
  bindColorbox();
  bindMarkdowns();
  $('a[data-toggle=modal]').on('click', showPopup);
  $('textarea.resizable').TextAreaResizer();
  
});

bindColorbox = function() {
  window.boxOptions = { opacity: 0.85, loop: false, current: "{current} / {total}", previous: "←", next: "→", close: "Esc", maxWidth: "80%", maxHeight: "100%", transition: "none" };
  if ($.browser.msie && $.browser.version < '8.0.0')
    window.boxOptions.transition = "none";
  $('[rel^="box-"]').colorbox(window.boxOptions);
  $('#cboxOverlay').append('<div id="cboxControls"></div>');
  $(document).bind('cbox_complete', function(){
    $('#cboxClose, #cboxCurrent, #cboxPrevious, #cboxNext').appendTo('#cboxControls');
    $('#cboxClose, #cboxCurrent, #cboxPrevious, #cboxNext').click(function(e) {
      e.stopPropagation();
    });
    $(document.body).css('overflow-y', 'scroll');
  });
  $(document).bind('cbox_closed', function(){
    $(document.body).css('overflow-y', 'auto');
  });
};

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

bindDatetime = function() {
  $('input.datetime').each(function() {
    if (!$(this).hasClass('datetime-added')) {
      $(this).wrap('<div class="input-prepend date"></div>');
      $(this).before('<span class="add-on"><i class="icon-calendar"></i></span>');
      $(this).siblings('.add-on').click(function() { $(this).siblings('input')[0].focus() });
      $(this).datetimepicker( { format: 'yyyy-mm-dd hh:ii:ss', weekStart: 1, language: 'ru', autoclose: true } );
      $(this).on('show', function(e) { $(e.target).select(); });
      $(this).addClass('datetime-added');
    }
  });
};

showPopup = function() {
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
};

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
  
  $('input.search-query').on('keydown keyup change', function() {
    var val = $('input.search-query').val();
    $("a.thumbnail div.caption").closest('li').show();
    if (val != "")
      $("a.thumbnail div.caption").not(":contains(" + val + ")").closest('li').hide();
  });
  
};

//Create parent
bindDialogCreateParent = function() {
  var form = $('#modal-dialog').find('form');
  $('#parent_title').focus();
  $(form).submit(function() { $('a.save-dialog').click(); return false } );
  $('a.save-dialog').click(function(e) {
    $.ajax({
      type: 'POST',
      url: form.prop('action'),
      data: form.serialize(),
      success: function(jqXHR, textStatus, errorThrown) {
        if (typeof jqXHR === 'string') {
          alert(jqXHR);
        }else{
          if (jqXHR.key) {
            $('select[id$='+jqXHR.field+']')
              .append('<option value="'+jqXHR.key+'">'+jqXHR.value+'</option>')
              .val(jqXHR.key);
            $('#modal-dialog').modal('hide');
          }
        }
      },
      error: function(jqXHR, textStatus, errorThrown) {
        alert(textStatus);
      }
    });
    return false;
  });
};

bindDialogFileUpload = function() {
  var thumbs = $('.tab-content > .active .thumbnails');
  var uploader = thumbs.children().first();
  var placeholder = uploader.find('.placeholder');
  var input = $('.tab-content > .active .fileinput-button input');
  var counter = null;
  input.fileupload({
    dataType: 'html',
    dropZone: thumbs,
    limitConcurrentUploads: 2,
    formData: { folder_id: thumbs.closest('.tab-pane').attr('id') },
    add: function(e, data) {
      /* this fancy animation freezes everywhere
      var file = data.files[0];
      var new_li = thumbs.children().last().clone();
      var new_a = new_li.find('a').attr('href', '');
      var new_img = new_a.find('img').attr('src','/images/grey-thumb.png')
      var new_div = new_a.find('div').text(file.name);
      new_img.wrap('<div class="scene"></div>');
      new_img.after('<div class="curtain"></div>');
      if (window.FileReader) {
        var reader = new FileReader();
        reader.onloadend = function() {
          new_img[0].src = reader.result;
          new_img.on('load', function() {
            $(this).removeClass('wide narrow').addClass( ( ( this.width / this.height  ) < 1.3 ) ? 'narrow' : 'wide' );
          });
        }
        reader.readAsDataURL(file);
      }
      uploader.after(new_li);
      data.context = new_li; */
      data.submit();
    },
    start: function(e) {
      old_caption = uploader.find('.caption').replaceWith('<div class="progress progress-striped active"><div class="bar" style="width: 0%;"></div></div>');
      counter = $({number:0})
      placeholder.css('font-size', '60px');
    },
    always: function (e, data) {
      var new_li = $(data.result);
      /* this fancy animation freezes everywhere
      data.context.replaceWith(new_li); */
      new_li.insertAfter(uploader);
      new_li.css('width', 0).animate({width: 140});
    },
    progress: function (e, data) {
      /* this fancy animation freezes everywhere
      var bar = data.context.find('.curtain');
      bar.animate({ height: (100 - parseInt(100 * data.loaded / data.total, 10)) }, 800); */
    },
    progressall: function (e, data) {
      uploader.find('.progress .bar').animate({ width: parseInt(130 * data.loaded / data.total, 10) }, 100);
      //uploader.find('.placeholder').text( parseInt(100 * data.loaded / data.total, 10) );
      var progress = parseInt(100 * data.loaded / data.total, 10);
      counter.animate({number:Math.ceil(progress)}, {
        duration: 200,
        step: function() {
          placeholder.text('' + (this.number >= 99 ? 99 : Math.ceil(this.number)) + '%');
        }
      });
      uploader.find('input').attr('disabled', 'disabled');
    },
    stop: function (e) {
      uploader.find('.progress .bar').animate({ width: 130 }, 500, function() {
        uploader.find('.progress').replaceWith(old_caption);
      });
      placeholder.css('font-size', '100px').text( '+' );
      uploader.find('input').removeAttr('disabled');
      uploader.closest('.tab-pane.active').trigger('pane-loaded');
    }
  });
};

bindBlockType = function() {
  /*$.fn.editable.defaults.placeholder = '&nbsp;';*/
  var select = $('select[id$=block_type]');
  var area = $('textarea[id$=block_text]');

  var savedrange = [], watchrange = [], savedcontent = '';
  function handlepaste (elem, e) {
      var range = window.getSelection().getRangeAt(0);
      savedcontent = elem.innerHTML;
      watchrange = [range.startOffset, range.endOffset];
      if (range.startContainer == range.endContainer) {
        savedrange = watchrange;
      }else{
        var sibs = range.startContainer.parentNode.childNodes;
        var p = 0;
        for (var i = 0; i < sibs.length; i++) {
          if (sibs[i] == range.startContainer)
            savedrange[0] = p + range.startOffset;
          if (sibs[i] == range.endContainer)
            savedrange[1] = p + range.endOffset;
          p += (typeof sibs[i].innerHTML == 'string') ? sibs[i].outerHTML.length : sibs[i].length;
        }
      }
      waitforpastedata(elem);
      return true;
  }

  function waitforpastedata (elem) {
      var range = window.getSelection().getRangeAt(0);
      if (range.startOffset != watchrange[0] || range.endOffset != watchrange[1] || savedcontent.length != elem.innerHTML.length) {
          processpaste(elem);
      }
      else {
          setTimeout(function() {
              waitforpastedata(elem);
          },20);
      }
  }

  function processpaste (elem) {
      pastesize = elem.innerHTML.replace(/(<br>)?[\r\n]+/g,"<br>\n").length - savedcontent.length - savedrange[0] + savedrange[1];
      paste = elem.innerHTML.substr(savedrange[0], pastesize);
      if (elem.innerHTML.match(/\t|<table/)) {
        elem.innerHTML = savedcontent;
        var current = $(elem).closest('td');
        var offsetJ = current[0].cellIndex;
        var offsetI = current.parent()[0].rowIndex;

        var tt = table.find('table');

        trs = $(paste).find('tr');
        if (trs.length > 0) {
          var i = 0;
          trs.each(function() {
            if (tt.find('tr').length < i + 1 + offsetI) {
              var row = '<tr>';
              for (var x = tt.find('tr:last-child td').length; x > 0; x--)
                row += '<td> </td>';
              row += '</tr>';
              tt.append(row);
            }
            var tr = $(tt.find('tr')[i]);
            var j = 0;
            $(this).find('td, th').each(function() {
              if (tr.find('td, th').length < j + 1 + offsetJ) {
                tt.find('tr').append('<td> </td>');
                tr = $(tt.find('tr')[i]);
              }
              var td = tt[0].rows[offsetI+i].cells[offsetJ+j];
              $(td).text($.trim($(this).text()));
              j += 1;
            });
            i += 1;
          });
          edifyTable();
        }else{
          var trs = $(paste).text().replace(/(<br>|[\r\n])+$/,'').split(/<br>|[\n\r]+/);
          var i = 0;
          $.each(trs, function() {
            if (tt.find('tr').length < i + 1 + offsetI) {
              var row = '<tr>';
              for (var x = tt.find('tr:last-child td').length; x > 0; x--)
                row += '<td> </td>';
              row += '</tr>';
              tt.append(row);
            }
            var tr = $(tt.find('tr')[i]);
            var tds = this.split(/\t/);
            var j = 0;
            $.each(tds, function() {
              if (tr.find('td, th').length < j + 1 + offsetJ) {
                tt.find('tr').append('<td> </td>');
                tr = $(tt.find('tr')[i]);
              }
              var td = tt[0].rows[offsetI+i].cells[offsetJ+j];
              $(td).text($.trim(this));
              j += 1;
            });
            i += 1;
          });
          edifyTable();
        }
      }else if (elem.innerHTML.match(/<.*>/)) {
        text = $.trim($(paste.replace(/<br.*?>/,'[br-placeholder]').replace(/<\/div>/,'[br-placeholder]')).text()
          .replace(/\[br-placeholder\]/g,"\n")
          .replace(/([\r\n]+\s+)+/g,"\n"));
        elem.innerHTML = savedcontent.substr(0,savedrange[0]) + text + savedcontent.substr(savedrange[1]);

        var range = document.createRange();
        range.setStart(elem.firstChild, savedrange[0] + text.length);
        range.setEnd(elem.firstChild, savedrange[0] + text.length);

        var selection = window.getSelection();
        selection.removeAllRanges();
        selection.addRange(range);
      }
  }

  var controls = area.closest('.controls');
  controls.before('<div class="table controls edit-table">' + 
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
        the_table.find('tr').append('<td> </td>');
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
          row += '<td> </td>';
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

  cleanifyTable = function(html) {
    return html
      .replace(" class=\"\"", '')
      .replace(/\<\/tr\>/g, "</tr>\n")
      .replace(/\<tbody\>/g, "<tbody>\n")
      .replace(/<t(h|d)(.*?)>/g,'\n    <t$1$2>')
      .replace(/<t(h|d)(.*?)class=['"]?\w+['"]?(.*?)>/g,'<t$1$2$3>') // !!!FIXME
      .replace(/<t(h|d)(.*?)contenteditable="true"(.*?)>/g, '<t$1$2$3>')   // !!!FIXME
//      .replace(/<t(h|d)(.*?)>/g,'\n    <t$1$2>') 
//      .replace(/<t(h|d).*?(rowspan=['"]?\d+['"]?|colspan=['"]?\d+['"]?).*?(rowspan=['"]?\d+['"]?|colspan=['"]?\d+['"]?).*?>/g,'\n    <t$1 $2 $3>')
      .replace(/(?:\<br\>)?[\r\n\s]*<\/t(h|d)\>/g,'</t$1>')
      .replace(/\s+[\r\n]/g, "\n")
      .replace(/[\r\n]+/g, "\n")
  };

  edifyTable = function() {
    var clone = table.clone();
    clone.find('table').removeClass('table table-bordered');
    area.val(cleanifyTable(clone.html()));
    table.find('table td, table th').attr('contenteditable', 'true');
    table.find('table [contenteditable]')
      .on('paste', function(e) {
        handlepaste(this, e)
      })
      .on('focus', function() {
        var $this = $(this);
        //$this.css('white-space', 'pre').css('max-width', 'none');
        if (' ' == $this.html() || '&nbsp;' == $this.html())
          $this.html('<br>');
        $this.data('before', $this.html());
        return $this;
      }).on('blur keyup paste', function() { 
        var $this = $(this);
        if ($this.data('before') !== $this.html()) {
          $this.data('before', $this.html());
          $this.trigger('change');
        }
        return $this;
      })
      .on('blur', function() {
        var $this = $(this);
        //$this.css('white-space', 'normal').css('max-width', '240px');
        if ('' == $this.html() || '<br>' == $this.html())
          $this.html(' ');
        return $this;
      })
      .on('change', function() {
        var clone = table.clone();
        clone.find('table').removeClass('table table-bordered');
        area.val(cleanifyTable(clone.html()));
      });
  };

  //if (!area.val().match(/$\<table.*table\>^/) && area.val().length > 0 )
  //  select.parents('.control-group').remove();
  select.change(function() {
    var html = area.val();
    var wmdpanel = controls.find('[id^=wmd-button-bar]');
    switch (select.val()) {
    case "0":
      controls.show();
      wmdpanel.show();
      insert.hide();
      table_controls.hide();
      break;
    case "1":
      controls.show();
      wmdpanel.hide();
      insert.hide();
      table_controls.hide();
      break;
    case "2":
      controls.show();
      wmdpanel.hide();
      if ($.browser.msie || $.browser.opera)
        insert.show();
      else
        insert.hide();
      table_controls.show();
      table.html(html.indexOf('table') == -1 ? '<table class="table table-bordered"><tr><td> </td></tr></table>' : html);
      table.find('table').addClass('table table-bordered');
      edifyTable();
      break;
    }
  });
  $(function() {
    select.change();
  });

};

/* Default class modification */
$.extend( $.fn.dataTableExt.oStdClasses, {
    "sWrapper": "dataTables_wrapper",
    "sFilterInput": "search-query",
} );

/* API method to get paging information */
$.fn.dataTableExt.oApi.fnPagingInfo = function ( oSettings )
{
    return {
        "iStart":         oSettings._iDisplayStart,
        "iEnd":           oSettings.fnDisplayEnd(),
        "iLength":        oSettings._iDisplayLength,
        "iTotal":         oSettings.fnRecordsTotal(),
        "iFilteredTotal": oSettings.fnRecordsDisplay(),
        "iPage":          Math.ceil( oSettings._iDisplayStart / oSettings._iDisplayLength ),
        "iTotalPages":    Math.ceil( oSettings.fnRecordsDisplay() / oSettings._iDisplayLength )
    };
}

/* Bootstrap style pagination control */
$.extend( $.fn.dataTableExt.oPagination, {
    "bootstrap": {
        "fnInit": function( oSettings, nPaging, fnDraw ) {
            var oLang = oSettings.oLanguage.oPaginate;
            var fnClickHandler = function ( e ) {
                e.preventDefault();
                if ( oSettings.oApi._fnPageChange(oSettings, e.data.action) ) {
                    fnDraw( oSettings );
                }
            };

            $(nPaging).addClass('pagination').append(
                '<ul>'+
                    '<li class="prev disabled"><a href="#">«</a></li>'+
                    '<li class="next disabled"><a href="#">»</a></li>'+
                '</ul>'
            );
            var els = $('a', nPaging);
            $(els[0]).bind( 'click.DT', { action: "previous" }, fnClickHandler );
            $(els[1]).bind( 'click.DT', { action: "next" }, fnClickHandler );
        },

        "fnUpdate": function ( oSettings, fnDraw ) {
            var iListLength = 3;
            var oPaging = oSettings.oInstance.fnPagingInfo();
            var an = oSettings.aanFeatures.p;
            //var oPerPage = $(an[0]).closest('.page-control').find('.dataTables_filtered_total');
            //oPerPage.html(oPerPage.html().replace('_TOTAL_', ''+oPaging.iFilteredTotal));
            var i, j, sClass, iStart, iEnd;

            iStart = 1;
            iEnd = oPaging.iTotalPages;

            for ( i=0, iLen=an.length ; i<iLen ; i++ ) {
                // Remove the middle elements
                $('li:gt(0)', an[i]).filter(':not(:last)').remove();
                if (iStart >= iEnd) {
                  $('li', an[i]).hide();
                }else{
                  $('li', an[i]).show();
                  $(an[i]).show();
                  var iActive = oPaging.iPage + 1;
                  for ( j=iStart ; j<=iEnd ; j++ ) {
                      var bActive = (j == oPaging.iPage + 1);
                      var bInsert = false, bMore = false;
                      sClass = bActive ? 'class="active"' : '';
                      if (bActive) {
                        bInsert = true;
                      }else if (j == oPaging.iPage || j == oPaging.iPage + 2) {
                        bInsert = true;
                      }else if (j == iStart || j == iEnd) {
                        bInsert = true;
                      }else if (j <= iListLength + 2 && iActive - 1 <= iListLength) {
                        bInsert = true;
                      }else if (j >= iEnd - iListLength + 1 - 2 && iActive + 1 >= iEnd - iListLength + 1) {
                        bInsert = true;
                      }else if (j == iStart + 1 || j == iEnd - 1) {
                        bMore = true;
                      }
                      if (bInsert) {
                          $('<li '+sClass+'><a href="#">'+j+'</a></li>')
                              .insertBefore( $('li:last', an[i])[0] )
                              .bind('click', function (e) {
                                  e.preventDefault();
                                  oSettings._iDisplayStart = (parseInt($('a', this).text(),10)-1) * oPaging.iLength;
                                  fnDraw( oSettings );
                              } );
                      }
                      if (bMore) {
                          $('<li '+sClass+'><span>...</span></li>')
                              .insertBefore( $('li:last', an[i])[0] );
                      }
                  }
                }

                // Add the new list items and their event handlers
/*
                for ( j=iStart ; j<=iEnd ; j++ ) {
                    sClass = (j==oPaging.iPage+1) ? 'class="active"' : '';
                    $('<li '+sClass+'><a href="#">'+j+'</a></li>')
                        .insertBefore( $('li:last', an[i])[0] )
                        .bind('click', function (e) {
                            e.preventDefault();
                            oSettings._iDisplayStart = (parseInt($('a', this).text(),10)-1) * oPaging.iLength;
                            fnDraw( oSettings );
                        } );
                }

*/
/*
                var lis = $(an[i]).find('li:not(.prev):not(.next)');
                var active = $(an[i]).find('.active');
                while (lis.length > iListLength) {
                  var removed = lis.last().prev();
                  if (removed.get(0) != active.get(0) && removed.get(0) != active.next().get(0)) {
                    removed = removed;
                  }else{
                    removed = lis.first().next();
                    if (removed.get(0) != active.get(0) && removed.get(0) != active.prev().get(0)) {
                      removed = removed;
                    }else{
                      break;
                    }
                  }
                  removed.remove();
                  lis = $(an[i]).find('li:not(.prev):not(.next)');
                }

                lis = $(an[i]).find('li:not(.prev):not(.next)');
                if (parseInt(lis.first().text()) + 1 != parseInt(lis.first().next().text())) {
                }
*/
                // Add / remove disabled classes from the static elements
                if ( oPaging.iPage === 0 ) {
                    $('li:first', an[i]).addClass('disabled');
                } else {
                    $('li:first', an[i]).removeClass('disabled');
                }

                if ( oPaging.iPage === oPaging.iTotalPages-1 || oPaging.iTotalPages === 0 ) {
                    $('li:last', an[i]).addClass('disabled');
                } else {
                    $('li:last', an[i]).removeClass('disabled');
                }
            }
        }
    }
} );

jQuery.fn.dataTableExt.oSort['by-data-asc'] = function(a,b) {
    var x = $(a).data('sorter'), y = $(b).data('sorter');
    return ((x < y) ? -1 : ((x > y) ?  1 : 0));
};

jQuery.fn.dataTableExt.oSort['by-data-desc'] = function(a,b) {
    var x = $(a).data('sorter'), y = $(b).data('sorter');
    return ((x < y) ?  1 : ((x > y) ? -1 : 0));
};

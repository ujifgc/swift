/*
 * Easy Select Box 1.0.1
 * http://www.codefleet.com/easy-select-box
 * Replace select with custom html for easy styling via css.
 * Features: multiple instances, initial value specified by selected attribute, optional classname, optional speed
 * Tested: IE7, IE8, Chrome 10, FF3, Safari 3.2 windows, Opera 11
 * 
 * Copyright 2011, Nico Amarilla
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * License same as jQuery http://jquery.org/license
 */
(function($){
	$.fn.extend({ 
		//plugin name
		easySelectBox: function(options) {

			//Settings list and the default values
			var defaults = {
				className: 'easy-select-box',
				speed:0//speed of opening and closing drop down in ms
			};
			
			var options = $.extend(defaults, options);
		
    		return this.each(function() {
				var o =options;
				
				//Assign current element to variable, in this case is UL element
				var selectObj = $(this);
				//check if its a <select> tag
				if('select'!=selectObj[0].nodeName.toLowerCase()){
					return false;
				}
				
				var lists = selectObj.children('option');
				var easySelect = null;
				var initialVal = selectObj.val();
				var displayClass = "easy-select-box-disp";
				var initIndex = 0;
				
				//construct html
				var html = '';
				$.each(lists, function(i, el){
					html += '<li><a href="#" rel="'+$(el).val()+'">'+$(el).text()+'</a></li>';//place text
					if(initialVal==$(el).val()){
						initIndex = i;
					}
				});
				html = '<div class="'+o.className+'"><a class="'+displayClass+'" href="#">'+lists.eq(initIndex).text()+'</a><ul>'+html+'</ul></div>';
				
				//add to dom
				easySelect = $(html).insertAfter(selectObj);
				selectObj.hide();//hide the select element
				
				easySelect.data('o',o);//store the settings of the current easySelect's options
				
				//array that contains the data of all the easySelect on the document
				easySelectRegistry = $(document).data('easySelect');
				if(easySelectRegistry==null){//does not exist yet..
				   easySelectRegistry = new Array();//.. so we create it
				}
				easySelectRegistry.push(easySelect);//push the current easySelect into the array
				$(document).data('easySelect',easySelectRegistry);//store the array
				
				//Attach click event
				easySelect.click(function(e){
					if($(easySelect).children('ul').is(':visible')){
						$(easySelect).children('ul').slideUp(o.speed);
						easySelect.css('z-index',0).removeClass('open');
					} else {
						

						easySelectRegistry = $(document).data('easySelect');//get all easySelect in this document
						if(easySelectRegistry!=null){
							$.each(easySelectRegistry, function(){
								opts = $(this).data('o');//use this easySelect's options
								$(this).children('ul').slideUp(opts.speed);	
								$(this).css('z-index',0).removeClass('open');
							});
						}
						$(easySelect).children('ul').slideDown(o.speed);
						easySelect.css('z-index',1).addClass('open');
					}
					e.stopPropagation();
					return false;
				});
				
				//close when not clicked.
				$(document).click(function(){
					easySelectRegistry = $(document).data('easySelect');
					if(easySelectRegistry!=null){
						$.each(easySelectRegistry, function(){
							if($(this).children('ul').is(':visible')){
								opts = $(this).data('o');//use this easySelect's options
								$(this).removeClass('open').children('ul').slideUp(opts.speed);	
							}
						});
					}
				});

				//change value
				easySelect.children('ul').children('li').click(function(){									   
					easySelect.children('.'+displayClass).html($(this).children('a').html());	
					selectObj.children('option').removeAttr('selected');
					selectObj.find('option').eq($(this).index()).attr('selected','selected');//mark the selected option
				});
    		});
    	}
	});
})(jQuery);
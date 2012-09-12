﻿@card = FormsCard.by_slug @swift[:slug]
not_found  unless @card
@swift[:path_pages][-1] = Page.new :title => @card.title
case @opts[:method].to_sym
when :post
  @result = @card.fill request
  if @result.saved?
    flash[:notice] = 'Saved'
  else
    flash[:notice] = 'Error'
  end
else
  @result = FormsResult.new :forms_card => @card
end

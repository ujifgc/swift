cards = Bond.children_for( @page, 'FormsCard' ).published
cards = FormsCard.all(:kind => 'inquiry', :order => :created_at.desc).published if cards.count == 0
not_found  unless cards.count > 0

case swift.http_method
when /POST/i
  @card = FormsCard.get(params['forms_result']['card_id'])
  not_found unless @card

  if Option('forms_protection').include?('ip') && @card.forms_results.first( :origin => request.addr )
    redirect back
  end

  session[:load_it!]
  if Option('forms_protection').include?('session') && (session['forms_cards'].nil? || !session['forms_cards'].include?(@card.id.to_i))
    redirect back
  end

  unless @voted
    @result = @card.fill request
    if @result.saved?
      redirect back
    else
      redirect back
    end
  end
else
  @fresh_cards = []
  @cards_with_results = []
  ip_protected = Option('forms_protection').include?('ip')
  cards.each do |card|
    @cards_with_results << card if card.forms_results.count > 0
    if !ip_protected || card.forms_results.count(:origin => request.addr) == 0
      @fresh_cards << card
    end
  end 
end

case (@opts[:method] || :show).to_sym
when :poll
  @card = FormsCard.by_slug swift.slug
  not_found  unless @card
  swift.path_pages << Page.new( :title => @card.title )
  swift.resource = @card

  if @card.forms_results.first( :origin => request.addr )
    flash[:notice] = 'Already polled'
    redirect back
  end

  unless session['forms_cards'].include? @card.id
    flash[:notice] = 'Session severed'
    redirect back
  end

  swift.path_pages[-1] = Page.new :title => @card.title
  @result = @card.fill request
  if @result.saved?
    flash[:notice] = 'Saved'
    redirect back
  else
    flash[:notice] = 'Error'
  end
else
  @cards = Bond.children_for( @page, 'FormsCard' )
  @cards = FormsCard.all( :kind => 'inquiry', :order => :created_at.desc, :limit => 1 ).published  if @cards.empty?
  @cards.each do |c|
    next  if c.statistic.any? 
    incs = {}
    c.json.each do |field|
      case field[1][0].to_sym
      when :select 
        results = c.forms_results
        name = field[0]
        incs[name] = {}
        field[1][1].split("\r\n").each { |char| incs[name][char] = 0 }
        results.each do |r|
          next  unless r.json[name]
          incs[name][r.json[name]] ||=0
          incs[name][r.json[name]] += 1  
        end
      when :multiple 
        results = c.forms_results
        name = field[0]
        incs[name] = {}
        results.each do |r|
          next  unless r.json[name]
          r.json[name].each do |v|
            incs[name][v] ||=0
            incs[name][v] += 1 
          end 
        end
      end
    end
    c.statistic = incs
    c.save!
  end
end

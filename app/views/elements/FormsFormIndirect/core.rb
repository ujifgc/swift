@card = Bond.children_for( @page, 'FormsCard' ).first
not_found  unless @card
@swift[:path_pages][-1] = Page.new :title => @card.title

case @swift[:method]
when /POST/i
  @result = @card.fill request
  if @result.saved?
    @card.json.select do |k, v|
      v[0] == 'file'
    end.each do |k, v|
      files = params['forms_result'][k]
      files = [files]  unless files.kind_of? Array
      @result.json[k] = []
      files.each do |file|
        unless file.kind_of? Hash
          @result.json[k] << file
          next  
        end
        o = Asset.new
        o.title = file[:filename]
        o.upload_name = file[:filename]
        o.file = file[:tempfile]
        o.folder = @card.folder
        o.save
        @result.json[k] << o.id
      end
    end

    @result.save
    flash[:notice] = 'Saved'

    card = @card
    result = @result
    host = env['SERVER_NAME']
    [@card.receivers, result.json['E-mail']].select do |receiver|
      receiver.match(/^[\w\d.+-]+@[\w\d.+-]+(?:,\s*[\w\d.+-]+@[\w\d.+-]+)*$/)
    end.each do |receiver|
      email do
        @card_title = card.title
        @card = card
        @result = result
        @host = host
        @receiver = receiver

        from         "robot@#{@host}"
        to           @receiver
        subject      "Форма «#{@card_title}» заполнена"
        content_type 'text/html'
        body         render 'form_saved'
      end
    end
  else

    @card.json.select do |k, v|
      v[0] == 'file'
    end.each do |k, v|
      files = params['forms_result'][k]
      files = [files]  unless files.kind_of? Array
      @result.json[k] = []
      files.each do |file|
        unless file.kind_of? Hash
          @result.json[k] << file
          next  
        end
        o = Asset.new
        o.title = file[:filename]
        o.upload_name = file[:filename]
        o.file = file[:tempfile]
        o.folder = @card.folder
        o.save
        @result.json[k] << o.id
      end
    end

    flash[:notice] = 'Error'
  end
when /GET/i
  @result = FormsResult.new :card => @card
else
  halt 405, '405 method not allowed'
end

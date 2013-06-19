@opts[:kind] ||= :form
if md = @swift[:slug].match( /(show|post)\/(.*)/ )
  @swift[:slug] = md[2]
  @opts[:method] = md[1]
  if @opts[:method] == 'post' && @swift[:method] != 'POST'
    throw :output, redirect( @swift[:uri].gsub(/\/post\//, '/show/') )
  else
    throw :output, element( 'Forms' + @opts[:kind].to_s.camelize, *@args, @opts )
  end
end
if md = @swift[:slug].match( /(poll)\/(.*)/ )
  @opts[:kind] = :inquiry
  @opts[:method] = md[1]
  @swift[:slug] = md[2]
  throw :output, element( 'Forms' + @opts[:kind].to_s.camelize, *@args, @opts )
end
@forms = FormsCard.all( :kind => @opts[:kind] ).published

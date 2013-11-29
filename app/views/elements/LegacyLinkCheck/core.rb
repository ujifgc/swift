require 'open-uri'
@legacy_uri = 'http://' + @opts[:host] + swift.uri
begin
  status = open(@legacy_uri).status
rescue OpenURI::HTTPError => e
  @legacy_uri = 'http://' + @opts[:host]
else 
  redirect @legacy_uri  if status.first == "200" && @opts[:redirect]
end

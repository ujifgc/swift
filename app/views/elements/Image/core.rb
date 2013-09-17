@image = Image.get @args[0]
throw :output, "[Image ##{@args[0]} missing]"  unless @image

@identity[:class] += ' sized'  if @opts[:width] || @opts[:height]
@identity[:alt] = @opts[:title].blank? ? @image.title : @opts[:title]

@outlet = case @opts[:outlet]
when nil
  @opts[:instance] ? @image.file.outlets[:thumb] : @image.file
when ''
  @image.file
else
  @image.file.outlets[@opts[:outlet].to_sym]
end
throw :output, "[Image ##{@args[0]} outlet '#{@opts[:outlet]||'thumb'}' missing]"  unless @outlet

styles = []
[:width, :height].each do |dim|
  if @opts[dim]
    styles << if @opts[dim].index('px') || !@opts[dim].index(/[^\d]/)
      @identity[dim] = @opts[dim].to_i
      "#{dim}:#{@opts[dim].to_i}px"
    else
      "#{dim}:#{@opts[dim]}"
    end
  end
end
@identity[:style] = styles.join(';')  if styles.any?

@folders = if @opts[:folders]
  case @opts[:folders]
  when Symbol, String
    Folder.all( :slug => Array(@opts[:folders]) )
  else
    @opts[:folders]
  end
else
  Bond.children_for(@page, 'Folder')
end
@folders = Folder.with :images  unless @folders.any?
throw :output, "[No bound folders for FoldersList]"  unless @folders.any?

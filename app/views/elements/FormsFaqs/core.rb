session[:forms_faq_ids] ||= []

@my_faqs = FormsFaq.all(:id => session[:forms_faq_ids])

filter = {}

@faqs_count = FormsFaq.published.count

@per_page = @opts[:per_page] || 10
@pages_count = (@faqs_count - 1) / @per_page + 1
@current_page = params[:page] ? params[:page].to_i : 1
filter.merge! :limit => @per_page, :offset => (@current_page - 1) * @per_page, :order => [ :publish_at.desc, :id.desc ]

@faqs = FormsFaq.published.all(filter)

Logger params

case swift.http_method
when /POST/i
  if file = params[:forms_faq].delete('asset')
    if file.kind_of?(Hash)
      o = Asset.new
      o.title = file[:filename]
      o.file = file
      o.folder = Folder.by_slug('faq') || Folder.by_slug('assets') || Folder.first
      o.save
    else
      o = Asset.get(file)
    end
    params[:forms_faq].update(:asset_id => o.id)
  end

  @faq = FormsFaq.create(params[:forms_faq].merge(:is_published => false))
  if @faq.saved?
    session[:forms_faq_ids] << @faq.id
    redirect swift.uri
  end
else
  if params[:forms_faq]
    @faq = FormsFaq.new(params[:forms_faq].merge(:is_published => false))
  else
    @faq = FormsFaq.new
  end
end

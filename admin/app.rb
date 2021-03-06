MODULE_GROUPS = {
  :content => [:pages, :blocks, :assets, :images, :folders],
  :news    => [:news_articles, :news_rubrics],
  :forms   => [:forms_cards, :forms_stats, :forms_results, :forms_faqs],
  :cat     => [:cat_nodes, :cat_cards, :cat_groups],
  :design  => [:layouts, :fragments, :elements, :codes],
  :admin   => [:accounts, :options],
}
BONDABLE_CHILDREN = %W(Page Folder Image FormsCard CatCard NewsRubric)
BONDABLE_PARENTS  = %W(Page CatNode NewsArticle Folder FormsCard)

class Admin < Padrino::Application
  MULTIPLE_EDIT_FIELDS = %W[news_rubric_id folder_id]

  register Padrino::Rendering
  register Padrino::Helpers
  helpers Swift::Helpers
  enable :sessions
  set :credentials_reader, :current_account
  set :credentials_accessor, :current_account
  disable :login_controller
  register Padrino::Login
  register Padrino::Access

  set :default_builder, 'AdminFormBuilder'
  set :protection, :except => :ip_spoofing
  set :protect_from_csrf, :except => [%r{^/dialogs/preview/}]

  set :pipeline, {
    :combine => Padrino.env == :production,
    :css => {
      :login => [
        'vendor/stylesheets/libraries/bootstrap.css',
        'assets/stylesheets/admin/96-monkey.css',
        'assets/stylesheets/login.css',
      ],
      :admin => [
        'vendor/stylesheets/libraries/bootstrap.css',
        'vendor/stylesheets/libraries/colorbox.css',
        'assets/stylesheets/admin/*.css',
      ]
    },
    :js => {
      :admin => [
        'vendor/javascripts/libraries/*.js',
        'vendor/javascripts/bootstrap/*.js',
        'vendor/javascripts/markdown/*.js',
        'assets/javascripts/admin-core.js',
      ]
    }
  }
  register RackPipeline::Sinatra

  # hookers
  before do
    Account.current = current_account
    I18n.locale = :ru

    translation = {}
    locales = Array(Option(:locales) || ['ru'])[1..-1]
    pattern = /^(#{Regexp.union(locales)})_(.+)$/

    params.each do |k,v|
      next  unless v.kind_of? Hash
      params[k].delete 'created_by_id'
      params[k].delete 'updated_by_id'
      params[k].delete 'account_id'  if params[k]['account_id'].blank?
      if Object.const_defined?(k.camelize)
        child_model = k.camelize.constantize
        params[k]['updated_by_id'] = current_account.id  if child_model.new.respond_to?(:updated_by_id)
        params[k]['account_id'] ||= current_account.id   if child_model.new.respond_to?(:account_id)
        params[k].each do |field, value|
          if field =~ pattern
            locale = $1
            translation[locale] ||= {}
            translation[locale][$2] = value
            params[k].delete(field)
          end
        end
      end
    end

    detect_current_model

    params.each do |k,v|
      if k.camelize == @model_name && @the_model
        params[k].each do |property_name, property_value|
          next if property_value.blank?
          if @the_model.properties[property_name].kind_of?(DataMapper::Property::DateTime)
            params[k][property_name] << DateTime.now.zone
          end
        end
      end
    end

    params[@model][:translation] = translation if params[@model] && translation.any?
  end

  # common routes
  route_verbs [:post, :put], '/assets/upload' do
    models, id = params[:folder_id].split('-')
    folder = Folder.get(id) || Folder.by_slug(models) || Folder.first
    model = case models
    when 'images'; Image
    when 'assets'; Asset
    else
      halt 400
    end

    @objects = []
    params[models].each do |upload|
      attributes = {
        :title => File.basename(upload[:filename], '.*').gsub('_', ' '),
        :file => upload,
        :created_by => current_account,
        :updated_by => current_account,
        :folder => folder,
      }
      @objects << model.create( attributes )
    end
    render 'dialogs/folder_images_object', :layout => false
  end

  # common routes
  post '/:controller/multiple' do
    return redirect url(:base, :index)  unless @the_model
    if params["check_#{@model}"].kind_of? Hash
      ids = params["check_#{@model}"].keys
      case params['_method']
      when 'delete'
        errors = []
        @the_model.all( :id => ids ).to_a.each do |o|
          o.destroy  or errors << o
        end
        if errors.any?
          flash[:error] = errors.map do |e|
            I18n.t( 'padrino.admin.multiple.not_destroyed', :objects => e.title || I18n.t("models.#{@models}.name") )
          end.join(', ')
        else
          flash[:notice] = I18n.t('padrino.admin.multiple.destroyed', :objects => I18n.t("models.#{@models}.name"))
        end
      when 'publish'
        break  unless @the_model.respond_to? :published
        @the_model.all( :id => ids ).to_a.each{ |o| o.publish! }
        flash[:notice] = I18n.t('padrino.admin.multiple.published', :objects => I18n.t("models.#{@models}.name"))
      when 'unpublish'
        break  unless @the_model.respond_to? :published
        @the_model.all( :id => ids ).to_a.each{ |o| o.unpublish! }
        flash[:notice] = I18n.t('padrino.admin.multiple.unpublished', :objects => I18n.t("models.#{@models}.name"))
      when 'multiedit'
        redirect url(:multiple, :edit, :models => @models, :ids => ids.join(' '))
      end
    end
    redirect url(@models, :index)
  end

  get '/:controller/multiple' do
    redirect url(@the_model ? @models : :base, :index)
  end

  get '/:controller/history', :with => :id do
    redirect url('/') unless @the_model
    object = @the_model.get(params[:id]) or not_found
    @objects = Protocol.for(object)
    render 'protocols/history'
  end

  set_access :admin, :designer, :auditor, :editor, :allow => :private
  get :private, :with => :path, :path => /.*/ do
    path, _, _ = CGI.unescape( request.env['REQUEST_URI'].gsub('+','%2B') ).gsub(url('/'),'').rpartition('?')
    if File.exists?(path)
      content_type `file -bp --mime-type '#{path}'`.to_s.strip
      File.binread path
    else
      not_found
    end
  end

  error 403 do
    @time = DateTime.now
    @error = I18n.t('error.forbidden')
    render 'base/error'
  end

  after do
    @expires || expires( -86400, :private, :must_revalidate, :no_cache, :no_store )
  end
end

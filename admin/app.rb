MODULE_GROUPS = {
  :content => [:pages, :blocks, :assets, :images, :folders],
  :news    => [:news_articles, :news_rubrics, :news_events],
  :forms   => [:forms_cards, :forms_stats, :forms_results],
  :cat     => [:cat_nodes, :cat_cards, :cat_groups],
  :design  => [:layouts, :fragments, :elements, :codes],
  :admin   => [:accounts, :options],
}
BONDABLE_CHILDREN = %W(Page Folder Image FormsCard CatCard NewsRubric)
BONDABLE_PARENTS  = %W(Page CatNode NewsArticle Folder FormsCard)

class Admin < Padrino::Application
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
  set :protect_from_csrf, :except => %r{^/login/auth/yandex/}

  use OmniAuth::Builder do
    options :path_prefix => '/login/auth'
    provider :open_id, :store => OpenID::Store::Filesystem.new(Padrino.root+'/tmp'), :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
    provider :open_id, :store => OpenID::Store::Filesystem.new(Padrino.root+'/tmp'), :name => 'yandex', :identifier => 'http://ya.ru/'
  end

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

    params.each do |k,v|
      next  unless v.kind_of? Hash
      params[k].delete 'created_by_id'
      params[k].delete 'updated_by_id'
      params[k].delete 'account_id'  if params[k]['account_id'].blank?
      if Object.const_defined?(k.camelize)
        child_model = k.camelize.constantize
        params[k]['updated_by_id'] = current_account.id  if child_model.new.respond_to?(:updated_by_id)
        params[k]['account_id'] ||= current_account.id   if child_model.new.respond_to?(:account_id)
      end
    end

    @the_model = begin
      @models = request.controller || params[:controller]
      @model = @models.singularize
      @models = @models.to_sym
      @model_name = @model.camelize
      @model = @model.to_sym
      Object.const_defined?(@model_name)  or throw :undefined
      @model_name.constantize
    rescue
      nil
    end
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
      end
    end
    redirect url(@models, :index)
  end

  get '/:controller/multiple' do
    redirect url(@the_model ? @models : :base, :index)
  end

  get '/private/*' do 
    path = Padrino.root + CGI.unescape( request.env['REQUEST_URI'].gsub('+','%2B') ).gsub(url('/'),'')
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

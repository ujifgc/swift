MODULE_GROUPS = {
  :content => %W(pages blocks assets images folders),
  :news    => %W(news_articles news_rubrics news_events),
  :forms   => %W(forms_cards forms_stats forms_results),
  :cat     => %W(cat_nodes cat_cards cat_groups),
  :design  => %W(layouts fragments elements codes),
  :admin   => %W(accounts options),
}
BONDABLE_CHILDREN = %W(Page Folder Image FormsCard CatCard NewsRubric)
BONDABLE_PARENTS  = %W(Page CatNode NewsArticle Folder FormsCard)

class Admin < Padrino::Application
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers
  register Padrino::Admin::AccessControl
  helpers Swift::Helpers
  use Rack::Session::File

  set :login_page, "/admin/sessions/new"
  set :default_builder, 'AdminFormBuilder'
  set :protection, :except => :ip_spoofing

  enable :store_location

  use OmniAuth::Builder do
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

  access_control.roles_for :any do |role|
    role.protect "/"
    role.allow "/sessions"
    role.allow "/auth"
    role.allow "/accounts/reset"
    role.allow "/accounts/edit"
    role.allow "/accounts/update"
    role.allow "/assets/login"
  end

  access_control.roles_for :editor do |role|
    role.project_module :pages, "/pages"
    role.project_module :images, '/images'
    role.project_module :assets, '/assets'
    role.project_module :blocks, '/blocks'
    role.project_module :folders, '/folders'

    role.project_module :news_articles, '/news_articles'
#    role.project_module :news_events, '/news_events'

    role.project_module :forms_results, '/forms_results'
    role.project_module :forms_stats, '/forms_stats'

    role.project_module :cat_nodes,  '/cat_nodes'
  end

  access_control.roles_for :auditor do |role|
    role.project_module :pages, "/pages"
    role.project_module :images, '/images'
    role.project_module :assets, '/assets'
    role.project_module :blocks, '/blocks'
    role.project_module :folders, '/folders'

    role.project_module :news_articles, '/news_articles'
    role.project_module :news_rubrics, '/news_rubrics'
#    role.project_module :news_events, '/news_events'

    role.project_module :forms_cards, '/forms_cards'
#    role.project_module :forms_stats, '/forms_stats'
    role.project_module :forms_results, '/forms_results'

    role.project_module :cat_nodes,  '/cat_nodes'
    role.project_module :cat_cards,  '/cat_cards'
    role.project_module :cat_groups, '/cat_groups'
  end

  access_control.roles_for :designer do |role|
    role.project_module :pages, "/pages"
    role.project_module :images, '/images'
    role.project_module :assets, '/assets'
    role.project_module :blocks, '/blocks'
    role.project_module :folders, '/folders'

    role.project_module :news_articles, '/news_articles'
    role.project_module :news_rubrics, '/news_rubrics'
 #   role.project_module :news_events, '/news_events'

    role.project_module :forms_cards, '/forms_cards'
#    role.project_module :forms_stats, '/forms_stats'
    role.project_module :forms_results, '/forms_results'

    role.project_module :cat_nodes,  '/cat_nodes'
    role.project_module :cat_cards,  '/cat_cards'
    role.project_module :cat_groups, '/cat_groups'

    role.project_module :fragments,  '/fragments'
    role.project_module :layouts,    '/layouts'
    role.project_module :elements,   '/elements'

    role.project_module :codes,      '/codes'
  end

  access_control.roles_for :admin do |role|
    role.project_module :pages, "/pages"
    role.project_module :images, '/images'
    role.project_module :assets, '/assets'
    role.project_module :blocks, '/blocks'
    role.project_module :folders, '/folders'

    role.project_module :news_articles, '/news_articles'
    role.project_module :news_rubrics, '/news_rubrics'
#    role.project_module :news_events, '/news_events'

    role.project_module :forms_cards, '/forms_cards'
#    role.project_module :forms_stats, '/forms_stats'
    role.project_module :forms_results, '/forms_results'

    role.project_module :cat_nodes,  '/cat_nodes'
    role.project_module :cat_cards,  '/cat_cards'
    role.project_module :cat_groups, '/cat_groups'

    role.project_module :fragments,  '/fragments'
    role.project_module :layouts,    '/layouts'
    role.project_module :elements,   '/elements'

    role.project_module :options,    '/options'
    role.project_module :codes,      '/codes'
    role.project_module :accounts,   '/accounts'
  end

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
  post_or_put = lambda do
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

  post '/assets/upload', &post_or_put
  put '/assets/upload', &post_or_put

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

  def do_auth(request)
    auth    = request.env["omniauth.auth"]
    account = Account.create_with_omniauth(auth)
    if account.saved?
      set_current_account account
      redirect_back_or_default url(:base, :index)
    else
      error = ''.html_safe
      error << content_tag(:code, "#{account.email}") << ': ' \
            << account.errors.to_a.flatten.join(', ') << ': ' << tag(:br) \
            << content_tag(:code, "#{account.provider}: #{account.uid}")
      flash[:error] = error
      set_current_account nil
      redirect url(:sessions, :new)
    end
  end

  post '/auth/:provider/callback' do
    do_auth request
  end

  get '/auth/:provider/callback' do
    do_auth request
  end

  get '/auth/failure' do
    flash[:error] = t 'login.error.' + params[:message]
    redirect '/admin/session/new'
  end

  get '/private/*' do 
    path = Padrino.root + CGI.unescape( request.env['REQUEST_URI'].gsub('+','%2B') ).gsub('/admin','')
    if File.exists?(path)
      content_type `file -bp --mime-type '#{path}'`.to_s.strip
      File.binread path
    else
      not_found
    end
  end

  after do
    @expires || expires( -86400, :private, :must_revalidate, :no_cache, :no_store )
  end
end

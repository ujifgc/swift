MODULE_GROUPS = {
  :content => %W(pages blocks assets images folders),
  :news    => %W(news_articles news_rubrics),
  :cat     => %W(cat_nodes cat_cards cat_groups),
  :admin   => %W(layouts fragments accounts),
}
BONDABLE_CHILDREN = [
  Page,
  Folder,
  Image,
  CatGroup,
  CatCard,
]
BONDABLE_PARENTS = [
  Page,
  CatNode,
  NewsArticle,
]

require 'omniauth-openid'
require 'openid/store/filesystem'

class Admin < Padrino::Application
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers
  register Padrino::Admin::AccessControl

  #set :session_id, 'swift.admin'.to_sym
  #use Rack::Session::DataMapper

  set :login_page, "/admin/sessions/new"
  set :default_builder, 'AdminFormBuilder'

  enable :sessions
  disable :store_location

  use OmniAuth::Builder do
    provider :open_id, :store => OpenID::Store::Filesystem.new('/tmp'), :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
    provider :open_id, :store => OpenID::Store::Filesystem.new('/tmp'), :name => 'yandex', :identifier => 'http://ya.ru/'
  end

  access_control.roles_for :any do |role|
    role.protect "/"
    role.allow "/sessions"
    role.allow "/auth"
  end

  access_control.roles_for :admin do |role|
    role.project_module :accounts, '/accounts'
    role.project_module :pages, "/pages"
    role.project_module :images, '/images'
    role.project_module :assets, '/assets'
    role.project_module :blocks, '/blocks'
    role.project_module :folders, '/folders'

    role.project_module :news_articles, '/news_articles'
    role.project_module :news_rubrics, '/news_rubrics'

    role.project_module :cat_nodes, '/cat_nodes'
    role.project_module :cat_cards, '/cat_cards'
    role.project_module :cat_groups, '/cat_groups'

    role.project_module :fragments, '/fragments'
    role.project_module :layouts, '/layouts'
  end

  # hookers
  before do
     #I18n.reload!  if Padrino.env == :development

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
  post '/:controller/multiple' do
    return redirect url(:base_index)  unless @the_model
    if params["check_#{@model}"].kind_of? Hash
      ids = params["check_#{@model}"].keys
      case params['_method']
      when 'delete'
        if @the_model.all( :id => ids ).destroy
          flash[:notice] = I18n.t('padrino.admin.multiple.destroyed', :objects => I18n.t("admin.#{@models}"))
        else
          flash[:error] = I18n.t('padrino.admin.multiple.not_destroyed', :objects => I18n.t("admin.#{@models}"))
        end
      when 'publish'
        break  unless @the_model.respond_to? :published
        @the_model.all( :id => ids ).to_a.each{ |o| o.publish! } #FIXME to_a for redis
        flash[:notice] = I18n.t('padrino.admin.multiple.published', :objects => I18n.t("admin.#{@models}"))
      when 'unpublish'
        break  unless @the_model.respond_to? :published
        @the_model.all( :id => ids ).to_a.each{ |o| o.unpublish! } #FIXME to_a for redis
        flash[:notice] = I18n.t('padrino.admin.multiple.unpublished', :objects => I18n.t("admin.#{@models}"))
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
    if account.new?
      flash[:error] = account.errors.to_a.flatten.join(', ') + ': ' + content_tag(:code, "#{account.email}<br>#{account.provider}: #{account.uid}")
      set_current_account nil
      redirect url(:sessions, :new)
    else
      set_current_account account
      redirect url(:base, :index)
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

end

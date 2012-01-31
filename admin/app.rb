class Admin < Padrino::Application
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers
  register Padrino::Admin::AccessControl

  set :login_page, "/admin/sessions/new"
  set :default_builder, 'AdminFormBuilder'

  enable  :sessions
  disable :store_location

  access_control.roles_for :any do |role|
    role.protect "/"
    role.allow "/sessions"
  end

  access_control.roles_for :admin do |role|
    role.project_module :pages, "/pages"
    role.project_module :accounts, "/accounts"
  end

  # hookers
  before do
    I18n.reload!  if Padrino.env == :development

    params.each do |k,v|
      next  unless v.kind_of? Hash
      params[k].delete 'created_by_id'
      params[k].delete 'updated_by_id'
      if Object.const_defined?(k.camelize) && k.camelize.constantize.new.respond_to?(:updated_by_id)
        params[k]['updated_by_id'] = current_account.id
      end
    end

    @the_model = begin
      @models = request.controller || params[:controller]
      @model = @models.singularize
      @model_name = @model.camelize
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
          flash[:notice] = "Some #{@models} destroyed"
        else
          flash[:error] = "Some #{@models} are busy, none destroyed"
        end
      when 'publish'
        break  unless @the_model.respond_to? :published
        @the_model.all( :id => ids ).to_a.each{ |o| o.publish! } #FIXME to_a for redis
      when 'unpublish'
        break  unless @the_model.respond_to? :published
        @the_model.all( :id => ids ).to_a.each{ |o| o.unpublish! } #FIXME to_a for redis
      end
    end
    redirect url(@models.to_sym, :index)
  end
  
  get '/:controller/multiple' do
    return redirect url(:base_index)  unless @models
    redirect url(@models.to_sym, :index)
  end
  

end

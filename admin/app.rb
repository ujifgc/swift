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
    role.project_module :blocks, '/blocks'
    role.project_module :pages, "/pages"
    role.project_module :accounts, "/accounts"
  end

  # hookers
  before do
    params.each do |k,v|
      next  unless v.kind_of? Hash
      params[k].delete 'created_by_id'
      params[k].delete 'updated_by_id'
      if Object.const_defined?(k.camelize) && k.camelize.constantize.new.respond_to?(:updated_by_id)
        params[k]['updated_by_id'] = current_account.id
      end
    end
  end

  post '/:controller/multiple' do
    models = params[:controller].split('/').last
    model = models.singularize
    model_name = model.camelize
    return redirect url('/')   unless Object.const_defined?(model_name)
    the_model = model_name.constantize
    if params["check_#{model}"].kind_of? Hash
      ids = params["check_#{model}"].keys
      case params['_method']
      when 'delete'
        if the_model.all( :id => ids ).destroy
          flash[:notice] = "Some #{models} destroyed"
        else
          flash[:error] = "Some #{models} are busy, none destroyed"
        end
      end
    end
    redirect url(models.to_sym, :index)
  end
  
  get '/:controller/multiple' do
    models = params[:controller].split('/').last
    model = models.singularize
    model_name = model.camelize
    return redirect url('/')   unless Object.const_defined?(model_name)
    redirect url(models.to_sym, :index)
  end
  

end

#coding:utf-8
Admin.controllers :accounts do
  set_access :admin
  set_access :designer, :auditor, :editor, :user, :allow => [:edit, :update]

  before :update, :create do
    gid = params[:account].delete 'group_id'
    @group = Account.get(gid)
    unless @group && current_account.allowed(@group.role)
      @group = nil
    end
    @password = params[:account].delete 'password'  
    @password_confirmation = params[:account].delete 'password_confirmation'
  end

  get :index do
    filter = { :group_id.not => nil }
    if params[:group] == 'groups' && current_account.allowed?(:admin)
      filter = { :group_id => nil }
    end    
    @objects = Account.all filter
    render 'accounts/index'
  end

  get :new do
    @object = Account.new
    render 'accounts/new'
  end

  post :create do
    @object = Account.new(params[:account])
    @object.password = @password
    @object.password_confirmation = @password_confirmation
    @object.group = @group  if @group
    if @object.save
      flash[:notice] = pat('account.created')
      redirect url_after_save
    else
      flash.now[:notice] = pat('account.error')
      render 'accounts/new'
    end
  end

  get :show, :with => :id do
    @subject = Account.get(params[:id])
    if !@subject || ( @subject.id != current_account.id && !current_account.allowed?(:editor) )
      flash[:notice] = pat('account.dont_hack')
      redirect url(:accounts, :show, current_account.id)
    end
    @object = params[:object_type].constantize.get(params[:object_id].to_i)  rescue nil
    render 'accounts/show'
  end

  get :edit, :with => :id do
    @object = Account.get(params[:id])
    if !@object || ( @object.id != current_account.id && !current_account.allowed?(:admin) )
      flash[:notice] = pat('account.dont_hack')
      redirect url(:accounts, :edit, current_account.id)
    end
    unless @object.group
      flash[:error] = pat('account.cannot_edit_root_group')
      redirect back
    end
    render 'accounts/edit'
  end

  put :update, :with => :id do
    @object = Account.get(params[:id])
    if !@object || ( @object.id != current_account.id && !current_account.allowed?(:admin) )
      flash[:notice] = pat('account.dont_hack')
      redirect url(:accounts, :edit, current_account.id)
    end
    @object.attributes = params[:account]
    @group = nil  if @object.id == current_account.id
    @object.group = @group  if @group
    @object.attribute_set :updated_at, DateTime.now
    @object.password = @password
    @object.password_confirmation = @password_confirmation
    @object.crypted_password = 'dummy'  if @password.present? || @password_confirmation.present?
    if @object.save
      flash[:notice] = pat('account.updated')
      redirect params[:apply] ? url_after_save : (current_account.allowed?(:admin) ? url_after_save : url('/'))
    else
      render 'accounts/edit'
    end
  end

  delete :destroy, :with => :id do
    @object = Account.get(params[:id])
    if @object.destroy
      flash[:notice] = pat('account.destroyed')
    else
      flash[:error] = pat('account.not_destroyed')
    end
    redirect url(:accounts, :index)
  end
end

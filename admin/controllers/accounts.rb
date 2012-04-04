#coding:utf-8
Admin.controllers :accounts do

  before :update, :create do
    gid = params[:account].delete 'group_id'
    @group = Account.get(gid)
    @group = nil  unless current_account.allowed @group.role
    params[:account].delete 'password'  if params[:account]['password'].blank?
    params[:account].delete 'password_confirmation'  if params[:account]['password_confirmation'].blank?
    logger << params.inspect
  end

  get :index do
    @objects = Account.all :group_id.not => nil
    render 'accounts/index'
  end

  get :new do
    @object = Account.new
    render 'accounts/new'
  end

  post :create do
    @object = Account.new(params[:account])
    @object.group = @group  if @group
    if @object.save
      flash[:notice] = pat('account.created')
      redirect url(:accounts, :index)
    else
      flash[:notice] = pat('account.created')
      render 'accounts/new'
    end
  end

  get :edit, :with => :id do
    @object = Account.get(params[:id])
    render 'accounts/edit'
  end

  put :update, :with => :id do
    @object = Account.get(params[:id])
    @object.attributes = params[:account]
    @object.group = @group  if @group
    if @object.save
      flash[:notice] = pat('account.updated')
      redirect url(:accounts, :index)
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

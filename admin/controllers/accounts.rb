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

  get :reset do
    render 'accounts/reset', :layout => false
  end

  post :reset do
    account = Account.first :email => params[:email]
    if account
      code = Digest::SHA2.hexdigest(Digest::SHA1.hexdigest(account.inspect) + 'herjovFas8' + Date.today.to_s)[6..11]
      host = env['SERVER_NAME']
      if params[:reset]
        if code == params[:reset]
          pwd = `apg -qd -c#{rand(0..9)} -m8 -x8 -n1`  rescue Digest::SHA2.hexdigest(DateTime.now.to_s+rand(0..9).to_s).gsub(/[^\d]/,'')[0..5]
          account.password = account.password_confirmation = pwd
          account.crypted_password = Digest::SHA2.hexdigest(pwd)[0..5]  # dummy action to make account dirty
          if account.save
            email do
              @host = host
              @pwd = pwd
              @login = account.email
              @address = "http://#{@host}/admin"
              from "noreply@#{@host}"
              to   account.email
              subject  "resetting padrino password"
              body render 'reset_account_done'
            end
            set_current_account account
            flash[:notice] = pat('account.reset_done')
            redirect url(:base, :index)
          else
            flash[:error] = pat('account.save_failed')
            render 'accounts/reset', :layout => false
          end
        else
          flash[:error] = pat('account.code_wrong')
          render 'accounts/reset', :layout => false
        end              
      else
        email do
          @code = code
          @host = host
          from "noreply@#{@host}"
          to   account.email
          subject  "resetting padrino password"
          body render 'reset_account'
        end
        render 'accounts/reset', :layout => false
      end
    else
      params[:email] = nil
      flash[:error] = pat('account.doesnt_exist')
      render 'accounts/reset', :layout => false
    end
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

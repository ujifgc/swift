#coding:utf-8
Admin.controllers :accounts do

  before :update, :create do
    gid = params[:account].delete 'group_id'
    @group = Account.get(gid)
    @group = nil  unless current_account.allowed @group.role
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

  get_or_post_reset = lambda do
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
            mail_subject = I18n.t('padrino.admin.account.mail.reset_account_title', :host => host)
            email do
              @host = host
              @pwd = pwd
              @login = account.email
              @address = "http://#{@host}/admin"

              from     "noreply@#{@host}"
              to        account.email
              subject  mail_subject
              body render 'reset_account_done'
            end
            set_current_account account
            flash[:notice] = pat('account.reset_account_done')
            redirect url(:base, :index)
          else
            flash.now[:error] = pat('account.save_failed')
            render 'accounts/reset', :layout => 'login'
          end
        else
          flash.now[:error] = pat('account.code_wrong')
          render 'accounts/reset', :layout => 'login'
        end              
      else
        mail_subject = I18n.t('padrino.admin.account.mail.reset_account_title', :host => host)
        email do
          @code = code
          @host = host
          @login = account.email

          content_type 'text/html; charset=UTF-8'
          from    "noreply@#{@host}"
          to       account.email
          subject mail_subject
          body render 'reset_account'
        end
        flash.now[:notice] = pat('account.reset_initiated')
        render 'accounts/reset', :layout => 'login'
      end
    else
      flash.now[:notice] = pat('account.doesnt_exist')  if params.delete('email')
      render 'accounts/reset', :layout => 'login'
    end
  end

  get :reset, &get_or_post_reset
  post :reset, &get_or_post_reset

  post :create do
    @object = Account.new(params[:account])
    @object.group = @group  if @group
    if @object.save
      flash[:notice] = pat('account.created')
      redirect url_after_save
    else
      flash.now[:notice] = pat('account.created')
      render 'accounts/new'
    end
  end

  get :edit, :with => :id do
    @object = Account.get(params[:id])
    unless @object.group
      flash[:error] = pat('account.cannot_edit_root_group')
      redirect back
    end
    render 'accounts/edit'
  end

  put :update, :with => :id do
    @object = Account.get(params[:id])
    @object.attributes = params[:account]
    @object.group = @group  if @group
    @object.attribute_set :updated_at, DateTime.now
    @object.password = @password
    @object.password_confirmation = @password_confirmation
    if @object.save
      flash[:notice] = pat('account.updated')
      redirect url_after_save
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

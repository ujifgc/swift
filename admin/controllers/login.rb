Admin.controllers :login do
  layout 'login'
  set_access :*

  get :new, :map => '/login' do
    render 'new'
  end

  post :create, :map => '/login' do
    if authenticate || install_first_admin
      restore_location
    else
      params.delete 'password'
      flash.now[:error] = pat('login.wrong_password')
      render 'new'
    end
  end

  route_verbs [:get, :delete], :destroy do
    save_credentials(nil)
    redirect url(:login, :new)
  end

  route_verbs [:get, :post], :reset do
    account = Account.first :email => params[:email]
    if account
      host = env['SERVER_NAME']
      if params[:reset]
        if account.reset_code == params[:reset]
          password = account.new_password
          if account.save
            mail_subject = I18n.t('padrino.admin.account.mail.reset_account_title', :host => host)
            html = render('mailers/reset_account_done', :layout => false, :locals => { :email => account.email, :password => password, :admin => absolute_url('') })
            Mail.email({
              :from    => "noreply@#{host}",
              :to      => account.email,
              :subject => mail_subject,
              :html    => html,
            })
            flash[:notice] = pat('account.reset_account_done')
            save_credentials(account)
            restore_location
          else
            flash.now[:error] = pat('account.save_failed')
            render 'reset', :layout => 'login'
          end
        else
          flash.now[:error] = pat('account.code_wrong')
          render 'reset', :layout => 'login'
        end              
      else
        mail_subject = I18n.t('padrino.admin.account.mail.reset_account_title', :host => host)
        html = render('mailers/reset_account', :layout => false, :locals => { :account => account })
        Mail.email({
          :from    => "noreply@#{host}",
          :to      => account.email,
          :subject => mail_subject,
          :html    => html,
        })
        flash.now[:notice] = pat('account.reset_initiated').html_safe
        render 'reset', :layout => 'login'
      end
    else
      flash.now[:notice] = pat('account.doesnt_exist')  if @email = params.delete('email')
      render 'reset', :layout => 'login'
    end
  end

  get :failure do
    flash[:error] = I18n.t('login.error.' + params[:message].html_safe)
    redirect url(:login, :new)
  end
end
